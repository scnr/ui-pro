class HttpResponse < ActiveRecord::Base
    belongs_to :responsable, polymorphic: true

    serialize :headers, Hash
end
