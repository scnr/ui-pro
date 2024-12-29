require 'active_support/concern'

module ScanStates
    extend ActiveSupport::Concern

    ACTIVE_STATES   = %w(initializing restoring scanning pausing paused aborting suspending cleanup)
    FINISHED_STATES = %w(aborted failed completed)
    INACTIVE_STATES = FINISHED_STATES + %w(suspended)
    STATES          = ACTIVE_STATES + INACTIVE_STATES

    included do
        scope :active, -> do
            where status: ACTIVE_STATES
        end
        scope :inactive, -> do
            where status: INACTIVE_STATES
        end
        scope :finished, -> do
            where status: FINISHED_STATES
        end

        STATES.each do |state|
            scope state, -> do
                where status: state
            end

            define_method "#{state}?" do
                self.status == state
            end
        end
    end

    def active?
        ACTIVE_STATES.include? status
    end

    def inactive?
        INACTIVE_STATES.include? status
    end

    def finished?
        FINISHED_STATES.include? status
    end

end
