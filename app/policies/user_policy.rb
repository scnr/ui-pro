class UserPolicy < ApplicationPolicy

    def index?
        admin?
    end

    def show?
        admin? or user == record
    end

    def update?
        admin?
    end

    def destroy?
        return false if user == record
        admin?
    end

    def permitted_attributes
        return [] if !admin?

        [:role, :profile_override]
    end

end
