class ScanScheduler
module Helpers
module Slots

    # 210MB for each browser -- **very** generous.
    SLOT_BROWSER_SIZE  = 210 * 1024 * 1024

    # 780MB for each instance -- **very** generous.
    SLOT_INSTANCE_SIZE = 780 * 1024 * 1024

    # @return   [Integer]
    #   Amount of new scans that can be safely run in parallel, currently.
    def slots_free
        # Manual mode, user gave us a value.
        if (max_parallel_scans = Setting.get.max_parallel_scans)
            free = max_parallel_scans - slots_used

        # Auto-mode, pick the safest restriction, RAM vs CPU.
        else
            free = [
                # See how many scans we can fit into the available memory.
                System.memory_free / slot_memory_size,

                # See how many CPU cores are free.
                #
                # Well, they may not be really free, other stuff on the machine
                # could be using them to a considerable extent, but we can only
                # do so much.
                System.cpu_count - slots_used
            ].min.to_i
        end

        free > 0 ? free : 0
    end

    # @return   [Integer]
    #   Amount of scans that are currently active.
    def slots_used
        active_instance_count
    end

    # @return   [Integer]
    #   Amount of scans that can be safely run in parallel, in total.
    def slots_total
        slots_used + slots_free
    end

    # @return   [Integer]
    #   Amount of memory (in bytes) each scan requires.
    def slot_memory_size
        (Setting.get.browser_cluster_pool_size * SLOT_BROWSER_SIZE) +
            SLOT_INSTANCE_SIZE
    end

end
end
end
