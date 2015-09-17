class Issue < ActiveRecord::Base
    DEFAULT_STATES = 'trusted'
    STATES         = %w(trusted untrusted false_positive fixed)

    belongs_to :revision, counter_cache: true
    belongs_to :reviewed_by_revision, class_name: 'Revision',
               foreign_key: 'reviewed_by_revision_id'

    belongs_to :site, counter_cache: true
    belongs_to :scan, counter_cache: true

    has_many :siblings, class_name: 'Issue', foreign_key: :digest, primary_key: :digest

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

    before_save :set_owners

    STATES.each do |state|
        scope state, -> do
            where( state: state )
        end

        define_method "#{state}?" do
            self.state == state
        end
    end

    IssueTypeSeverity::SEVERITIES.each do |severity|
        scope "#{severity}_severity", -> do
            joins(:severity).where( 'issue_type_severities.name = ?', severity )
        end
    end

    scope :by_severity, -> { includes(:severity).order IssueTypeSeverity.order_sql }
    scope :reviewed,    -> { where.not reviewed_by_revision: nil }

    default_scope do
        includes(:type).includes(:vector).by_severity.
            order('issue_types.name asc').order( state_order_sql )
    end

    def has_proofs?
        remarks.any? || !proof.blank? ||
            (page && page.dom && page.dom.execution_flow_sinks &&
                page.dom.execution_flow_sinks.any?)
    end

    def reviewed_by_revision?
        !!reviewed_by_revision
    end

    def auto_reviewed?
        reviewed_by_revision?
    end

    def auto_review_status
        return if !auto_reviewed?

        case state
            when 'trusted', 'untrusted'
                'regression'
            else
                state
        end
    end

    def to_s
        "#{type.name} in #{vector.kind} input '#{vector.affected_input_name}'"
    end

    def revision=( rev )
        self.scan = rev.scan
        self.site = rev.site
        super rev
    end

    def self.digests
        pluck(:digest).uniq
    end

    def self.count_states
        # We need to remove the order since we're counting fields that are
        # used for ordering and PG will go ape.
        counted_states = reorder('').group( 'issues.state' ).count

        states = {}
        Issue::STATES.each do |state|
            states[state.to_s] = counted_states[state.to_s]
            states[state.to_s] ||= 0
        end

        states
    end

    def self.count_severities
        # We need to remove the order since we're counting fields that are
        # used for ordering and PG will go ape.
        counted_severities = reorder('').joins(:severity).
            group( 'issue_type_severities.name' ).count

        severities = {}
        IssueTypeSeverity::SEVERITIES.each do |severity|
            severities[severity.to_s] = counted_severities[severity.to_s]
            severities[severity.to_s] ||= 0
        end

        severities
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
            digest:         issue.digest,
            signature:      issue.signature,
            proof:          issue.proof,
            state:          options[:state] || state_from_native_issue( issue ),
            active:         issue.active?,
            page:           IssuePage.create_from_arachni( issue.page ),
            referring_page: IssuePage.create_from_arachni( issue.referring_page ),
            vector:         Vector.create_from_arachni( issue.vector ),
            remarks:        issue_remarks,
            platform:       (IssuePlatform.find_by_shortname( issue.platform_name.to_s ) if issue.platform_name)
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

    def self.state_from_native_issue( issue )
        issue.trusted? ? 'trusted' : 'untrusted'
    end

    def update_state( state, reviewed_by_revision = nil )
        Issue.reorder('').where( digest: digest ).
            update_all(
            state:                   state,
            reviewed_by_revision_id: reviewed_by_revision ?
                       reviewed_by_revision.id : nil
        )
    end

    def get_sitemap_entry( options = {} )
        revision.sitemap_entries.create_with(options).
            find_or_create_by( url: options[:url] )
    end

    def set_owners
        # The revision setter handles this.
        self.revision = revision
    end

end
