class ScanPolicy < ApplicationPolicy
    alias :scan :model

    allow_admin_or :index, :show, :new, :create do |user, scan|
        next if scan.site.unverified?
        scan.site.user == user || user.has_shared_site?( scan.site )
    end

    allow_admin_or :update, :edit, :destroy do |user, scan|
        next if scan.site.unverified?
        scan.site.user == user
    end

end
