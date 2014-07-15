class ScansController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_site
    before_action :set_scan, only: [:show, :edit, :update, :destroy]

    after_action :refresh_scan_table_partial, only: [:create, :update, :destroy]

    # GET /scans
    # GET /scans.json
    def index
        authorize @site
        redirect_to @site
    end

    # GET /scans/1
    # GET /scans/1.json
    def show
    end

    # GET /scans/new
    def new
        @scan = @site.scans.new
        authorize @scan
    end

    # GET /scans/1/edit
    def edit
    end

    # POST /scans
    # POST /scans.json
    def create
        @scan = @site.scans.new(scan_params)
        authorize @scan

        respond_to do |format|
            if @scan.save
                format.html { redirect_to [@site, @scan], notice: 'Scan was successfully created.' }
                format.json { render :show, status: :created, location: @scan }
            else
                format.html { render :new }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /scans/1
    # PATCH/PUT /scans/1.json
    def update
        respond_to do |format|
            if @scan.update(scan_params)
                format.html { redirect_to [@site, @scan], notice: 'Scan was successfully updated.' }
                format.json { render :show, status: :ok, location: @scan }
            else
                format.html { render :edit }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /scans/1
    # DELETE /scans/1.json
    def destroy
        @scan.destroy
        respond_to do |format|
            format.html { redirect_to site_scans_url, notice: 'Scan was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    private

    def set_site
        @site = current_user.sites.find_by_id( params[:site_id] ) ||
            current_user.shared_sites.find_by_id( params[:site_id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site

        @scans = @site.scans
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_scan
        @scan = @site.scans.find( params[:id] )

        raise ActionController::RoutingError.new( 'Scan not found.' ) if !@scan

        authorize @scan
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scan_params
        params.require(:scan).permit( :name, :description, :enabled )
    end

    def refresh_scan_table_partial
        refresh_partial [:table, @site, :scans]
    end
end
