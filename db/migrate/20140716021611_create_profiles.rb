class CreateProfiles < ActiveRecord::Migration[5.1]
    def change
        create_table :profiles do |t|
            t.belongs_to :user

            t.boolean  "default"
            t.string   "name"
            t.text     "description"

            t.binary     "checks"
            t.binary     "plugins"

            t.boolean  "audit_links"
            t.boolean  "audit_forms"
            t.boolean  "audit_cookies"
            t.boolean  "audit_cookies_extensively"
            t.boolean  "audit_headers"
            t.boolean  "audit_jsons"
            t.boolean  "audit_xmls"
            t.boolean  "audit_ui_forms"
            t.boolean  "audit_ui_inputs"
            t.boolean  "audit_parameter_names"
            t.boolean  "audit_with_extra_parameter"
            t.boolean  "audit_with_both_http_methods"
            t.binary     "audit_exclude_vector_patterns"
            t.binary     "audit_include_vector_patterns"

            t.integer  "scope_page_limit"
            t.binary     "scope_exclude_path_patterns"
            t.binary     "scope_exclude_content_patterns"
            t.boolean  "scope_exclude_binaries"
            t.binary     "scope_include_path_patterns"
            t.integer  "scope_dom_depth_limit"
            t.integer  "scope_directory_depth_limit"

            t.timestamps
        end

        add_index :profiles, :name, unique: true
    end
end
