class SchedulePolicy < ApplicationPolicy
    alias :schedule :record

    allow_authenticated :index

    allow_admin_or :show do |user, schedule|
        next if schedule.scan.site.unverified?
        schedule.scan.site.user == user || user.has_shared_site?( schedule.scan.site )
    end

    allow_admin_or :create, :update, :destroy do |user, schedule|
        next if schedule.scan.site.unverified?
        schedule.scan.site.user == user
    end

    def permitted_attributes
        [:month_frequency, :day_frequency, :start_at, :stop_after_hours, :stop_suspend]
    end

end
