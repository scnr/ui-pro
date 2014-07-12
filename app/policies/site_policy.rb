class SitePolicy < Policy
    alias :site :model

    allow_authenticated :index, :new, :create

    allow_admin_or :show do |user, site|
        site.user == user || user.has_shared_site?( site )
    end

    allow_admin_or :edit, :update, :destroy do |user, site|
        site.user == user
    end

end
