class ApplicationPolicy
    attr_reader :user, :record

    class <<self
        def allow( *actions, &block )
            prepare_actions( actions ).each do |action|
                define_method "#{action}?" do
                    block ? block.call( user, record, self ) : true
                end
            end
        end

        def allow_authenticated( *actions )
            allow( actions ) { |user| !!user }
        end

        def allow_admin_or( *actions, &block )
            allow( actions ) do |user, record, policy|
                policy.admin? || (user && block.call( user, record, policy ))
            end
        end

        private

        def prepare_actions( actions )
            actions.flatten.compact
        end
    end

    def initialize( user, record )
        @user   = user
        @record = record
    end

    def admin?
        user && user.admin?
    end

    def admin_or( &block )
        admin? || block.call
    end

    def index?
        false
    end

    def show?
        scope.where( id: record.id ).exists?
    end

    def create?
        false
    end

    def new?
        create?
    end

    def update?
        false
    end

    def edit?
        update?
    end

    def destroy?
        false
    end

    def scope
        Pundit.policy_scope!( user, record.class )
    end
end
