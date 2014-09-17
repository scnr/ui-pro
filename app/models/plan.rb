class Plan < ActiveRecord::Base
    has_many :scans

    has_one :profile_override, as: :profile_overridable, dependent: :destroy,
            autosave: true
    accepts_nested_attributes_for :profile_override
end
