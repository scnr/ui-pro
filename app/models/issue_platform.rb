class IssuePlatform < ActiveRecord::Base
    belongs_to :type, class_name: 'IssuePlatformType',
               foreign_key: 'issue_platform_type_id'
end
