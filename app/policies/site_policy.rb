class SitePolicy < Policy
    alias :site :model

    allow_authenticated :index, :new, :create

    allow_admin_or :show, :edit, :update, :destroy do |user, site|
        user.has_site? site
    end

end
