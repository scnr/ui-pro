class IssuePlatformType < ActiveRecord::Base
    has_many :platforms, class_name: 'IssuePlatform',
             foreign_key: 'issue_platform_type_id'
end
