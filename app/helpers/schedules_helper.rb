module SchedulesHelper

    NEARBY_RANGE = 24.hours

    def render_schedule( schedule )
        render partial: '/shared/schedule', locals: { schedule: schedule }
    end

    def render_frequency( schedule )
        if schedule.frequency_simple?
            schedule.human_frequency
        else
            "<kbd>#{schedule.frequency_cron}</kbd>".html_safe
        end
    end

    # TODO: Take into account Schedule#stop_after_hours, if it prevents overlaps
    # don't show nearby scans.
    # Also use the last duration when calculating the nearby threshold/range thing. (?)
    def nearby_scans( time )
        nearby = []

        if !@_nearby_scans_candidates
            @_nearby_scans_candidates = @site.scans.scheduled

            if @scan
                @_nearby_scans_candidates =
                    @_nearby_scans_candidates.where.not( id: @scan.id )
            end
        end

        @_nearby_scans_candidates.each do |scan|
            scan.schedule.step_through do |occurrence, otime|
                next if !nearby_schedule?( time, otime )

                nearby << {
                    scan:       scan,
                    time:       otime,
                    dynamic:    scan.schedule.dynamic?,
                    occurrence: occurrence
                }
            end
        end

        nearby
    end

    def nearby_schedule?( time, other )
        (time - other).abs < NEARBY_RANGE
    end

    def schedule_path( schedule )
        edit_site_scan_path( schedule.scan.site_id, schedule.scan_id )
    end

end
