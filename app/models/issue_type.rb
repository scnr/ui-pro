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
        includes(:severity).joins(:severity).order( order_by_severity ).order(name: :asc)
    end
    default_scope { by_severity }

    def self.order_by_severity
        ret = 'CASE'
        IssueTypeSeverity::SEVERITIES.each_with_index do |p, i|
            ret << " WHEN issue_type_severities.name = '#{p}' THEN #{i}"
        end
        ret << ' END'
    end

end
