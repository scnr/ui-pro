class Plan < ActiveRecord::Base
    has_many :users

    has_one :profile, dependent: :destroy, autosave: true
    accepts_nested_attributes_for :profile

    before_create :build_profile
end
