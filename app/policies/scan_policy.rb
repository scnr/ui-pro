class ScanPolicy < ApplicationPolicy
    alias :scan :record

    allow_admin_or :index, :show, :create do |user, scan|
        next if scan.site.unverified?
        scan.site.user == user || user.has_shared_site?( scan.site )
    end

    allow_admin_or :update, :destroy do |user, scan|
        next if scan.site.unverified?
        scan.site.user == user
    end

    def permitted_attributes
        permitted = [:name, :description, :plan_id]

        # Don't allow the scan profile to be changed once a scan has been
        # created unless requested by an admin.
        if scan == Scan || admin?
            permitted += [ :profile_id, :profile_override ]
        end

        permitted << { schedule_attributes: SchedulePolicy.new( user, record ).permitted_attributes }
    end

end
