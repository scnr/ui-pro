class IssuePageDomStackFrame < ActiveRecord::Base
    belongs_to :with_dom_stack_frame, polymorphic: true, optional: true
    has_one    :function, as: :with_dom_function,
               class_name: 'IssuePageDomFunction', dependent: :destroy

    def self.create_from_engine( frame )
        create(
            url:      frame.url,
            line:     frame.line,
            function: IssuePageDomFunction.create_from_engine( frame.function )
        )
    end
end
