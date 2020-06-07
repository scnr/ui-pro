class SiteProfile < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include ProfileRpcHelpers
    include ProfileAttributes
    include ProfileImport
    include ProfileExport

    events skip: [:created_at, :updated_at],
                    # If this is a copy made by a revision don't bother.
                    unless: Proc.new { |t| t.revision_id }

    belongs_to :site, optional: true
    belongs_to :revision, optional: true

    def to_s
        "Settings for #{site}"
    end
end
