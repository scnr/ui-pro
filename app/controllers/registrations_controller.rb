class RegistrationsController < Devise::RegistrationsController
    before_action :enforce_limit, except: [:edit, :update]

    private

    def enforce_limit
        return if User.count == 0
        fail 'User limit has been reached.'
    end
end
