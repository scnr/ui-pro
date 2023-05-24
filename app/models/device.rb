class Device < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include WithScannerOptions
    include ProfileImport
    include ProfileExport
    include ProfileDefaultHelpers

    # Broadcasts callbacks.
    after_create_commit :broadcast_create_job
    after_update_commit :broadcast_update_job
    after_destroy_commit :broadcast_destroy_job

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

    private

    def broadcast_create_job
        Broadcasts::Devices::CreateJob.perform_later(id)
    end

    def broadcast_update_job
        Broadcasts::Devices::UpdateJob.perform_later(id)
    end

    def broadcast_destroy_job
        Broadcasts::Devices::DestroyJob.perform_later(id)
    end
end
