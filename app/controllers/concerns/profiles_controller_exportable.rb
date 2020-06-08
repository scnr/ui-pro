module ProfilesControllerExportable
    extend ActiveSupport::Concern

    def show
        mi = model_instance

        respond_to do |format|
            format.html
            format.js { render mi }
            format.json do
                set_download_header 'json'
                render body: mi.export( JSON )
            end
            format.yaml do
                set_download_header 'yaml'
                render body: mi.export( YAML )
            end
            format.sep do
                set_download_header 'sep'
                render body: mi.to_scanner_options.to_yaml
            end
        end
    end

    private

    def set_download_header( extension )
        name = model_instance.name
        [ "\n", "\r", '"' ].each { |k| name.gsub!( k, '' ) }

        headers['Content-Disposition'] =
            "attachment; filename=\"SCNR::Pro #{model_name} - #{name}.#{extension}\""
    end

end
