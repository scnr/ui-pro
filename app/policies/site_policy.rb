class SitePolicy < Policy
    alias :site :model

    allow_authenticated :index, :new, :create

    allow_admin_or :show do |user, site|
        next if site.unverified?
        site.user == user || user.has_shared_site?( site )
    end

    allow_admin_or :destroy, :verification, :verify do |user, site|
        site.user == user
    end

    allow_admin_or :edit, :invite_user do |user, site|
        next if site.unverified?
        site.user == user
    end

end
