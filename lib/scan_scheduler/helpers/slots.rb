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
        if (max_parallel_scans = Settings.max_parallel_scans)
            free = max_parallel_scans - slots_used

        # Auto-mode, pick the safest restriction, RAM vs CPU.
        else
            free = slots_free_auto
        end

        free > 0 ? free : 0
    end

    # @return   [Integer]
    #   Amount of new scans that can be safely run in parallel, currently.
    #
    #   The decision is based on the available resources alone, user options
    #   from {Setting#max_parallel_scans} is ignored.
    def slots_free_auto
        [ slots_memory_free, slots_cpu_free ].min.to_i
    end

    # @return   [Integer]
    #   Amount of scans that can be safely run in parallel, in total.
    #
    #   The decision is based on the available resources alone, user options
    #   from {Setting#max_parallel_scans} is ignored.
    def slots_total_auto
        slots_used + slots_free_auto
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
    #   Amount of scans we can fit into the available memory.
    #
    #   Works based on slots, available memory isn't currently free memory but
    #   memory that is unallocated.
    def slots_memory_free
        slot_unallocated_memory / slot_memory_size
    end

    # See how many CPU cores are free.
    #
    # Well, they may not be really free, other stuff on the machine could be
    # using them to a considerable extent, but we can only do so much.
    #
    # @return   [Integer]
    def slots_cpu_free
        System.cpu_count - slots_used
    end

    # @param    [Integer]   pid
    #
    # @return   [Integer]
    #   Remaining memory for the scan, in bytes.
    #
    #   If memory use exceeds {#slot_memory_size} it will return a negative number.
    def slot_remaining_memory_for( pid )
        slot_memory_size - System.memory_for_process_group( pid )
    end

    # @return   [Integer]
    #   Amount of memory (in bytes) available for future scans.
    def slot_unallocated_memory
        # Free memory right now.
        free_mem = System.memory_free

        # Remove allocated memory to figure out how much we can really spare.
        #
        # TODO: Better keep track of PIDs from the Scheduler, other PIDs may creep
        # in to the generalized Manager.
        Arachni::Processes::Manager.pids.each do |pid|
            remaining = slot_remaining_memory_for( pid )

            # Scan matched or exceeded its allocation, no adjustment necessary.
            next if remaining <= 0

            # Mark the remaining allocated memory as unavailable.
            free_mem -= remaining
        end

        free_mem
    end

    # @return   [Integer]
    #   Amount of memory (in bytes) to allocate to each scan.
    def slot_memory_size
        (Settings.browser_cluster_pool_size * SLOT_BROWSER_SIZE) +
            SLOT_INSTANCE_SIZE
    end

end
end
end
