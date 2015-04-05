class SiteProfile < ActiveRecord::Base
    include ProfileRpcHelpers
    include ProfileAttributes
    include ProfileImport
    include ProfileExport

    belongs_to :site
end
