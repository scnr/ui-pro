class PlanPolicy < ApplicationPolicy
    alias :plan :record

    def permitted_attributes
        [
            :name, :description, :enabled, :price,
            { profile_attributes: PlanProfilePolicy.new(user, PlanProfile).permitted_attributes }
        ]
    end

end
