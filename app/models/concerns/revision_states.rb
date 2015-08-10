require 'active_support/concern'

module RevisionStates
    extend ActiveSupport::Concern
    include ScanStates

    included do
        ScanStates::STATES.each do |state|
            define_method "#{state}!" do
                update( status: state )
            end
        end
    end

    def status=( s )
        scan.status = s
        scan.save
        super( s )
    end

end
