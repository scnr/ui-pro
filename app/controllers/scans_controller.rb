class ScansController < ApplicationController
    include IssuesSummary

    before_filter :authenticate_user!

    before_action :set_site
    before_action :set_scan, only: [:show, :edit, :update, :destroy]

    # GET /scans
    # GET /scans.json
    def index
        redirect_to @site
    end

    # GET /scans/1
    # GET /scans/1.json
    def show
        @issues_summary = issues_summary_data(
            site:      @site,
            sitemap:   @scan.sitemap_entries,
            scans:     [@scan],
            revisions: @scan.revisions,
            issues:    @scan.issues
        )
    end

    # GET /scans/new
    def new
        @scan = @site.scans.new
        @scan.build_schedule
    end

    # GET /scans/1/edit
    def edit
    end

    # POST /scans
    # POST /scans.json
    def create
        @scan = @site.scans.new(scan_params)

        respond_to do |format|
            if @scan.save
                refresh_scan_table_partial

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
                refresh_scan_table_partial

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
        refresh_scan_table_partial

        respond_to do |format|
            format.html { redirect_to site_scans_url, notice: 'Scan was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    private

    def set_site
        @site = current_user.sites.find_by_id( params[:site_id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site

        @scans = @site.scans
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_scan
        @scan = @site.scans.find( params[:id] )

        raise ActionController::RoutingError.new( 'Scan not found.' ) if !@scan
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scan_params
        permitted = params.require(:scan).permit( permitted_attributes )

        # TODO: Write specs for this.
        if permitted[:profile_id].to_i > 0
            # Fail if user tries to set a profile they do not own.
            current_user.profiles.find( params[:scan][:profile_id] )
        end

        permitted
    end

    def permitted_attributes
        [:name, :description, :profile_id,
         { schedule_attributes: [:month_frequency, :day_frequency, :start_at, :stop_after_hours, :stop_suspend] }]
    end

    def refresh_scan_table_partial
        refresh_partial [:table, @site, :scans]
    end
end
