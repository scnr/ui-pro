class CreateSiteRoles < ActiveRecord::Migration
    def change
        create_table :site_roles do |t|
            t.belongs_to :site

            # Frozen copy at the time of Revision creation.
            t.belongs_to :revision

            t.string :name
            t.text   :description

            t.text   :session_check_url
            t.text   :session_check_pattern

            t.text   :scope_exclude_path_patterns

            t.string :login_type

            t.text   :login_form_url
            t.text   :login_form_parameters

            t.text   :login_script_code

            t.timestamps
        end
    end
end
