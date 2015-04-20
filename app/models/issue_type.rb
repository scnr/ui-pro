class IssueType < ActiveRecord::Base
    belongs_to :severity, class_name: 'IssueTypeSeverity',
             foreign_key: 'issue_type_severity_id'

    has_and_belongs_to_many :tags, class_name: 'IssueTypeTag',
             foreign_key: 'issue_type_tag_id',
             join_table: 'issue_types_issue_type_tags'

    has_many :references, class_name: 'IssueTypeReference',
             foreign_key: 'issue_type_id', dependent: :destroy

    has_many :issues

    scope :by_severity, -> do
        includes(:severity).joins(:severity).
            order( IssueTypeSeverity.order_sql ).order(name: :asc)
    end
    default_scope { by_severity }

    def cwe_url
        return if !cwe
        "http://cwe.mitre.org/data/definitions/#{cwe}.html"
    end

end
