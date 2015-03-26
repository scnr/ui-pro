class CustomFailure < Devise::FailureApp
    def redirect_url
        case User.count
            when 0
                new_user_registration_url

            when 1
                new_user_session_url

            else
                fail 'User limit has been violated.'
        end
    end

    # You need to override respond to eliminate recall
    def respond
        if http_auth?
            http_auth
        else
            redirect
        end
    end
end
