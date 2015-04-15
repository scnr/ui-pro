class UserAgentsController < ApplicationController
    include ProfilesControllerExportable
    include ProfilesControllerImportable

    before_filter :authenticate_user!

    before_action :set_user_agent,
                  only: [:show, :edit, :copy, :update, :default, :destroy]
    before_action :set_user_agents,
                  only: [:index, :default]

    before_action :authorize_edit,    only: [:edit, :update]
    before_action :authorize_destroy, only: [:destroy]

    PROFILE_EXPORT_PREFIX = 'Arachni Pro User-agent'

    respond_to :html

    def index
        respond_with(@user_agents)
    end

    def new
        @user_agent = UserAgent.new
        respond_with(@user_agent)
    end

    def edit
    end

    def copy
        @user_agent = @user_agent.dup
        render :new
    end

    def create
        @user_agent    = UserAgent.new(user_agent_params)
        flash[:notice] = 'UserAgent was successfully created.' if @user_agent.save
        respond_with(@user_agent)
    end

    def update
        flash[:notice] = 'UserAgent was successfully updated.' if @user_agent.update(user_agent_params)
        respond_with(@user_agent)
    end

    def default
        @user_agent.default!
        render partial: 'table', formats: :js
    end

    def destroy
        @user_agent.destroy
        respond_with(@user_agent)
    end

    private

    def authorize_edit
        return if @user_agent.revisions.empty?
        redirect_to @user_agent, error: 'Cannot edit a user-agent that has associated revisions.'
    end

    def authorize_destroy
        return if @user_agent.scans.empty?
        redirect_to @user_agent, error: 'Cannot delete a user-agent that has associated scans.'
    end

    def set_user_agent
        @user_agent = UserAgent.find(params[:id])
    end

    def set_user_agents
        @user_agents = UserAgent.all
    end

    def user_agent_params
        params.require(:user_agent).permit(
            :name,
            :http_user_agent,
            :browser_cluster_screen_width,
            :browser_cluster_screen_height
        )
    end
end
