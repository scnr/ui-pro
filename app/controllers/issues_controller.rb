class IssuesController < ApplicationController
    before_filter :authenticate_user!

    before_action :set_issue, only: [:show, :edit, :update]

    # GET /issues/1
    # GET /issues/1.json
    def show
    end

    # GET /issues/1/edit
    def edit
    end

    # PATCH/PUT /issues/1
    # PATCH/PUT /issues/1.json
    def update
        respond_to do |format|
            if @issue.update(issue_params)
                format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
                format.json { render :show, status: :ok, location: @issue }
            else
                format.html { render :edit }
                format.json { render json: @issue.errors, status: :unprocessable_entity }
            end
        end
    end

    private

    def set_issue
        @issue = Issue.find( params[:id] )
    end

    def issue_params
        params[:issue]
    end
end
