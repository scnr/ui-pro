module SiteRolesHelper

    def site_role_path( *args )
        if args.size == 1
            role = args.first
            super( role.site_id, role )
        else
            super( *args )
        end
    end

end
