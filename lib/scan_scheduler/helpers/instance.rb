class ScanScheduler
module Helpers
module Instance

    class Error < ScanScheduler::Error
        class InstanceNotFound < Error
        end
    end

    def initialize
        super

        reset_instance_state
    end

    # @return   [Integer]
    #   Amount of active scans.
    def active_instance_count
        @revision_id_to_instance_url.size
    end

    def active_instance_count_for_site( site )
        @site_instance_count[site.id] ||= 0
    end

    # Spawns a new instance and assigns it to the `revision`.
    #
    # @param    [Revision]  revision
    #
    # @return   [Arachni::RPC::Client::Instance]
    def spawn_instance_for( revision, &block )
        log_info_for revision, 'Spawning instance.'

        # Don't fork, we don't want the entire Rails env.
        instances.spawn fork: false do |instance|
            log_info_for revision, "Spawned instance at #{instance.url}"

            increment_active_instance_count_for_site revision.site

            @revision_id_to_instance_url[revision.id] = instance.url
            block.call instance
        end
    end

    # Kills the instance assigned to `revision`.
    #
    # @param    [Revision]  revision
    def kill_instance_for( revision )
        log_info_for revision, 'Killing instance.'

        url = instance_url_for( revision )

        Thread.new do
            begin
                instances.kill url

                log_info_for revision, 'Killed instance.'
            rescue => e
                log_exception e
            end
        end

        log_info_for revision, 'Removing from active list.'
        @revision_id_to_instance_url.delete revision.id
        decrement_active_instance_count_for_site revision.site

        nil
    end

    # Returns the instance assigned to `revision`.
    #
    # @param    [Revision]  revision
    #
    # @return   [Arachni::RPC::Client::Instance]
    def instance_for( revision )
        if !@revision_id_to_instance_url[revision.id]
            fail Error::InstanceNotFound,
                 prepare_log_line_for( revision, 'Instance not found.' )
        end

        # Connections are actually cached.
        instances.connect( @revision_id_to_instance_url[revision.id] )
    end

    # Returns the URL of the instance assigned to `revision`.
    #
    # @param    [Revision]  revision
    #
    # @return   [String]
    #   Instance URL.
    def instance_url_for( revision )
        @revision_id_to_instance_url[revision.id]
    end

    def instances
        Arachni::Processes::Instances
    end

    # @private
    def reset_instance_state
        @site_instance_count         = {}
        @revision_id_to_instance_url = {}
    end

    private

    def increment_active_instance_count_for_site( site )
        active_instance_count_for_site( site )

        @site_instance_count[site.id] += 1
    end

    def decrement_active_instance_count_for_site( site )
        active_instance_count_for_site( site )

        @site_instance_count[site.id] -= 1
    end

end
end
end
