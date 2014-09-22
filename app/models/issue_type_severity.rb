class IssueTypeSeverity < ActiveRecord::Base
    has_many :types, class_name: 'IssueType'
    has_many :issues, through: :types

    [:high, :medium, :low, :informational].each do |severity|
        define_singleton_method severity do
            where( name: severity.to_s ).first
        end
    end
end
