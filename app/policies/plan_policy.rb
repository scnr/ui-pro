class PlanPolicy < ApplicationPolicy
    alias :plan :record

    def permitted_attributes
        [:name, :description, :price, :profile_id]
    end

end
