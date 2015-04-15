module ProfilesControllerExportable
    extend ActiveSupport::Concern

    def show
        mi = model_instance

        respond_to do |format|
            format.html
            format.js { render mi }
            format.json do
                set_download_header 'json'
                render text: mi.export( JSON )
            end
            format.yaml do
                set_download_header 'yaml'
                render text: mi.export( YAML )
            end
            format.afp do
                set_download_header 'afp'
                render text: mi.to_rpc_options.to_yaml
            end
        end
    end

    private

    def model_instance
        instance_variable_get "@#{model_param_name}"
    end

    def model
        controller_name.classify.constantize
    end

    def model_param_name
        controller_name.singularize
    end

    def model_name
        model.model_name.human
    end

    def set_download_header( extension )
        name = model_instance.name
        [ "\n", "\r", '"' ].each { |k| name.gsub!( k, '' ) }

        headers['Content-Disposition'] =
            "attachment; filename=\"Arachni Pro #{model_name} - #{name}.#{extension}\""
    end

end
