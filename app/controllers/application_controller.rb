class ApplicationController < ActionController::Base
    include ApplicationHelper

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # protect_from_forgery with: :exception

    def authenticate_user!( *args )
        sign_in( User.first )
        super( *args )
    end
end
