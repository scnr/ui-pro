class ProfileOverridePolicy < ApplicationPolicy

    def permitted_attributes
        return [] if !admin?

        ProfilePolicy.new( user, record ).permitted_attributes +
            GlobalProfilePolicy.new( user, record ).permitted_attributes +
            [:scope_page_limit]
    end

end
