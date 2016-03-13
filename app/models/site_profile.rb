class SiteProfile < ActiveRecord::Base
    include WithEvents
    include ProfileRpcHelpers
    include ProfileAttributes
    include ProfileImport
    include ProfileExport

    has_paper_trail skip: [:created_at, :updated_at],
                    # If this is a copy made by a revision don't bother.
                    unless: Proc.new { |t| t.revision_id }

    belongs_to :site
    belongs_to :revision

    def to_s
        "Settings for #{site}"
    end
end
