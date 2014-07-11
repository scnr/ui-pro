class SitesController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_site, only: [:show, :edit, :update, :destroy]

    # GET /sites
    # GET /sites.json
    def index
        @sites = current_user.sites
        authorize Site
    end

    # GET /sites/1
    # GET /sites/1.json
    def show
    end

    # GET /sites/new
    def new
        @site = current_user.sites.new
        authorize @site
    end

    # GET /sites/1/edit
    def edit
    end

    # POST /sites/1/invite_user
    def invite_user
    end

    # POST /sites
    # POST /sites.json
    def create
        @site = Site.new(site_params)
        @site.users << current_user
        authorize @site

        respond_to do |format|
            if @site.save
                format.html { redirect_to @site, notice: 'Site was successfully created.' }
                format.json { render :show, status: :created, location: @site }
            else
                format.html { render :new }
                format.json { render json: @site.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /sites/1
    # PATCH/PUT /sites/1.json
    def update
        respond_to do |format|
            if @site.update(site_params)
                format.html { redirect_to @site, notice: 'Site was successfully updated.' }
                format.json { render :show, status: :ok, location: @site }
            else
                format.html { render :edit }
                format.json { render json: @site.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /sites/1
    # DELETE /sites/1.json
    def destroy
        @site.destroy
        respond_to do |format|
            format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_site
        @site = current_user.sites.find_by_id( params[:id] )

        raise ActionController::RoutingError.new( 'Scan not found.' ) if !@site

        authorize @site
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
        params.require(:site).permit( :verification_method, :protocol, :host, :port)
    end
end
