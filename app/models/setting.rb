class Setting < ActiveRecord::Base
    include ProfileRpcHelpers
    include ProfileAttributes

    validates :max_parallel_scans, numericality: { greater_than: 0 }
    validate  :validate_max_parallel_scans

    def self.get
        first
    end

    private

    def validate_max_parallel_scans
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
