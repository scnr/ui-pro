class SitePolicy < ApplicationPolicy
    alias :site :record

    class Scope < Scope
        def non_admin_resolve
            # Select both shared and owned sites.
            scope.joins( '
                LEFT OUTER JOIN "sites_users"
                  ON "sites_users"."site_id" = "sites"."id"'
            ).where(
                '"sites_users"."user_id" = ? OR "sites"."user_id" = ?',
                user, user
            )
        end
    end

    allow_authenticated :index, :create

    allow_admin_or :show do |user, site|
        next if site.unverified?
        site.user == user || user.has_shared_site?( site )
    end

    allow_admin_or :destroy, :verification, :verify do |user, site|
        site.user == user
    end

    allow_admin_or :update, :invite_user do |user, site|
        next if site.unverified?
        site.user == user
    end

end
