class Plan < ActiveRecord::Base
    has_many :scans

    has_one :profile, dependent: :destroy, autosave: true, class_name:'PlanProfile'
    accepts_nested_attributes_for :profile
end
