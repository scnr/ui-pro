class PlanPolicy < ApplicationPolicy
    alias :plan :record

    def permitted_attributes
        [
            :name, :description, :enabled, :price,
            {
                profile_override_attributes:
                    ProfileOverridePolicy.new( user, ProfileOverride ).permitted_attributes
            }
        ]
    end

end
