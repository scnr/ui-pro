module ProfilesControllerImportable
    extend ActiveSupport::Concern

    def import
        index_url = url_for( controller: controller_name, action: :index )

        if !params[model_param_name] ||
            !params[model_param_name][:file].is_a?( ActionDispatch::Http::UploadedFile )

            redirect_to index_url, alert: 'No file selected for import.'
            return
        end

        m = instance_variable_set(
            "@#{model_param_name}",
            model.import( params[model_param_name][:file] )
        )

        if !m
            redirect_to index_url,
                        alert: "Could not understand the #{model_name} format."
            return
        end

        respond_to do |format|
            format.html { render 'new' }
        end
    end

end
