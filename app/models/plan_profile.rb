class PlanProfile < ActiveRecord::Base
    include ProfileUtilities

    belongs_to :plan

    RPC_OPTS = [
        :scope_page_limit
    ]

end
