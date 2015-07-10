module SiteRolesHelper

    def site_role_path_js( site, role_or_id )
        "#{site_path( site )}#{site_role_fragment( role_or_id )}"
    end

    def site_role_fragment( role_or_id )
        id = role_or_id.is_a?( Integer ) ? role_or_id : role_or_id.id
        "#!/roles/#{id}"
    end

end
