class Profile < ActiveRecord::Base
    include WithEvents
    include ProfileRpcHelpers
    include ProfileAttributes
    include ProfileImport
    include ProfileExport
    include ProfileDefaultHelpers

    has_paper_trail

    belongs_to :user
    has_many   :scans, -> { order id: :desc }
    has_many   :revisions, through: :scans

    validates_presence_of   :description
    validate :validate_description

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :user

    def to_s
        name
    end

    private

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

end
