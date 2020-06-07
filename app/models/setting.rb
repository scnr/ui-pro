class Setting < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include ProfileRpcHelpers
    include ProfileAttributes

    events

    validates :max_parallel_scans, numericality: { greater_than: 0 },
              allow_nil: true
    validate  :validate_max_parallel_scans

    def max_parallel_scans_auto?
        max_parallel_scans.nil?
    end

    private

    def validate_max_parallel_scans
        return if !max_parallel_scans

        msgs = []

        Site.all.each do |site|
            next if max_parallel_scans >= site.max_parallel_scans

            msgs << "#{site.url} has a limit of #{site.max_parallel_scans}"
        end

        return if msgs.empty?

        errors.add :max_parallel_scans,
                   "cannot be less than any site setting (#{msgs.join(', ')})"
    end
end
