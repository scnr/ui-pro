class UsersController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_user, only: [:show, :update, :destroy]

    def index
        @users = User.all
        authorize User
    end

    def show
    end

    def update
        if @user.update_attributes( user_params )
            redirect_to users_path, notice: 'User updated.'
        else
            redirect_to users_path, alert: 'Unable to update user.'
        end
    end

    def destroy
        @user.destroy
        redirect_to users_path, notice: 'User deleted.'
    end

    private

    def set_user
        authorize @user = User.find( params[:id] )
    end

    def user_params
        params.require(:user).permit(*policy(@user || User).permitted_attributes)
    end

end
