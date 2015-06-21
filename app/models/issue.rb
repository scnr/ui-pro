class Issue < ActiveRecord::Base
    DEFAULT_STATES = 'trusted'
    STATES         = %w(trusted untrusted false_positive fixed)

    belongs_to :revision
    has_one :scan, through: :revision
    has_one :site, through: :scan

    belongs_to :page, class_name: 'IssuePage', foreign_key: 'issue_page_id',
               dependent: :destroy

    belongs_to :referring_page, class_name: 'IssuePage',
               foreign_key: 'referring_issue_page_id', dependent: :destroy

    belongs_to :type, class_name: 'IssueType', foreign_key: 'issue_type_id'
    has_one :severity, through: :type

    belongs_to :sitemap_entry, counter_cache: true

    belongs_to :platform, class_name: 'IssuePlatform',
               foreign_key: 'issue_platform_id'

    has_one  :vector, dependent: :destroy
    has_many :remarks, class_name: 'IssueRemark', foreign_key: 'issue_id',
                dependent: :destroy

    validates :state, presence: true, inclusion: { in: STATES }

    STATES.each do |state|
        scope state, -> do
            where( state: state )
        end
    end

    IssueTypeSeverity::SEVERITIES.each do |severity|
        scope "#{severity}_severity", -> do
            joins(:severity).where( 'issue_type_severities.name = ?', severity )
        end
    end

    scope :by_severity, -> { includes(:severity).order IssueTypeSeverity.order_sql }

    default_scope do
        includes(:type).includes(:vector).by_severity.
            order('issue_types.name asc').order( state_order_sql )
    end

    def to_s
        "#{type.name} in #{vector.kind} input '#{vector.affected_input_name}'"
    end

    def self.state_order_sql
        ret = 'CASE'
        STATES.each_with_index do |p, i|
            ret << " WHEN issues.state = '#{p}' THEN #{i}"
        end
        ret << ' END'
    end

    def self.unique_revisions
        Revision.where(
            id: select( 'issues.revision_id' ).pluck( 'issues.revision_id' ).uniq
        )
    end

    def self.max_severity
        issue = by_severity.first
        return if !issue

        issue.severity
    end

    def self.create_from_arachni( issue, options = {} )
        issue_remarks = []
        issue.remarks.each do |author, remarks|
            remarks.each do |remark|
                issue_remarks << IssueRemark.create( author: author, text: remark )
            end
        end

        issue = create({
            type:           IssueType.find_by_check_shortname( issue.check[:shortname] ),
            digest:         issue.digest.to_s,
            signature:      issue.signature,
            proof:          issue.proof,
            state:          (issue.trusted? ? 'trusted' : 'untrusted'),
            active:         issue.active?,
            page:           IssuePage.create_from_arachni( issue.page ),
            referring_page: IssuePage.create_from_arachni( issue.referring_page ),
            vector:         Vector.create_from_arachni( issue.vector ),
            remarks:        issue_remarks,
            platform:       (IssuePlatform.find_by_shortname( issue.platform_name.to_s ) if issue.platform_name),
       }.merge(options))

        issue.page.sitemap_entry = issue.get_sitemap_entry(
            url:  issue.page.dom.url,
            code: issue.page.response.code
        )
        issue.page.save

        issue.referring_page.sitemap_entry = issue.get_sitemap_entry(
            url:  issue.referring_page.dom.url,
            code: issue.referring_page.response.code
        )
        issue.referring_page.save

        issue.vector.sitemap_entry = issue.get_sitemap_entry(
            url:  issue.vector.action,
            code: issue.page.response.code
        )
        issue.vector.save

        issue.sitemap_entry = issue.vector.sitemap_entry
        issue.save

        issue
    end

    def get_sitemap_entry( options = {} )
        site = revision.scan.site
        site.sitemap_entries.find_by_url( options[:url] ) ||
            site.sitemap_entries.create( { revision: revision }.merge(options) )
    end

end
