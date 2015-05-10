class Issue < ActiveRecord::Base
    STATES = %w(trusted untrusted false_positive)

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

    has_one  :vector,  as: :with_vector, dependent: :destroy
    has_many :remarks, class_name: 'IssueRemark', foreign_key: 'issue_id',
                dependent: :destroy

    validates :state, presence: true, inclusion: { in: STATES }

    IssueTypeSeverity::SEVERITIES.each do |severity|
        scope "#{severity}_severity", -> do
            joins(:severity).where( 'issue_type_severities.name = ?', severity )
        end
    end

    scope :by_severity, -> { includes(:severity).order IssueTypeSeverity.order_sql }
    default_scope do
        includes(:type).includes(:vector).by_severity.order('issue_types.name asc')
    end

    def to_s
        "#{type.name} in #{vector.kind} input '#{vector.affected_input_name}'"
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

        create({
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
    end

end
