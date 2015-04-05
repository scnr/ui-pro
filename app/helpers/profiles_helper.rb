module ProfilesHelper
    include FrameworkHelper

    def messages_for( attribute )
        render partial: 'shared/profile_attribute_messages', locals: { attribute: attribute }
    end

    def render_options( plugin_name, plugin_info, configuration = {}, disabled = false )
        tpl = "#{Rails.root}/app/views/profiles/plugin_options/#{plugin_name}/#{params[:action]}.html.erb"
        opts = {
            plugin_name:   plugin_name,
            info:          plugin_info,
            configuration: configuration,
            disabled:      disabled
        }

        if File.exist? tpl
            render file: tpl, locals: opts
        else
            render partial: 'profiles/plugin_options/generic', locals: opts
        end
    end

end
