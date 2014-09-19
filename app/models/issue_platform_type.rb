class IssuePlatformType < ActiveRecord::Base
    has_many :platforms, class_name: 'IssuePlatform'
end
