class PlanProfilePolicy < ApplicationPolicy

    def permitted_attributes
        [ :scope_page_limit ]
    end

end
