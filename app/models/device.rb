class Device < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include WithScannerOptions
    include ProfileImport
    include ProfileExport
    include ProfileDefaultHelpers

    events
    set_scanner_options(
        device_user_agent:   String,
        device_width:        Integer,
        device_height:       Integer,
        device_pixel_ratio:  Float,
        device_touch:        :bool
    )

    has_many :scans, -> { order id: :desc }
    has_many :revisions, through: :scans

    validates :name, presence: true, uniqueness: true
    validates :device_user_agent, presence: true
    validates :device_width, numericality: true, presence: true
    validates :device_height, numericality: true, presence: true

    def to_s
        name
    end
end
