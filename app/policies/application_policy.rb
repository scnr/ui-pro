class ApplicationPolicy
    attr_reader :user, :model

    class <<self
        def allow( *actions, &block )
            prepare_actions( actions ).each do |action|
                define_method "#{action}?" do
                    block ? block.call( user, model, self ) : true
                end
            end
        end

        def allow_authenticated( *actions )
            allow( actions ) { |user| !!user }
        end

        def allow_admin_or( *actions, &block )
            allow( actions ) do |user, model, policy|
                policy.admin? || (user && block.call( user, model, policy ))
            end
        end

        private

        def prepare_actions( actions )
            actions.flatten.compact
        end
    end

    def initialize( user, model )
        @user  = user
        @model = model
    end

    def admin?
        user && user.admin?
    end

    def admin_or( &block )
        admin? || block.call
    end

end
