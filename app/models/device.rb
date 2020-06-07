class Device < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include ProfileRpcHelpers
    include ProfileAttributes
    include ProfileImport
    include ProfileExport
    include ProfileDefaultHelpers

    events

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
