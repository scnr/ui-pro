class UserAgent < ActiveRecord::Base
    include WithEvents
    include ProfileRpcHelpers
    include ProfileAttributes
    include ProfileImport
    include ProfileExport
    include ProfileDefaultHelpers

    has_paper_trail

    has_many :scans, -> { order id: :desc }
    has_many :revisions, through: :scans

    validates :name, presence: true, uniqueness: true
    validates :http_user_agent, presence: true
    validates :browser_cluster_screen_width, numericality: true, presence: true
    validates :browser_cluster_screen_height, numericality: true, presence: true

    def to_s
        name
    end
end
