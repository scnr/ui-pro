class CreateProfiles < ActiveRecord::Migration
    def change
        create_table :profiles do |t|
            t.belongs_to :user
            t.boolean  "default"
            t.string   "name"
            t.text     "description"

            t.text     "checks"
            t.text     "plugins"

            t.boolean  "audit_links"
            t.boolean  "audit_forms"
            t.boolean  "audit_cookies"
            t.boolean  "audit_cookies_extensively"
            t.boolean  "audit_headers"
            t.boolean  "audit_jsons"
            t.boolean  "audit_xmls"
            t.boolean  "audit_parameter_names"
            t.boolean  "audit_with_extra_parameter"
            t.boolean  "audit_with_both_http_methods"
            t.text     "audit_exclude_vector_patterns"
            t.text     "audit_include_vector_patterns"

            t.integer  "scope_page_limit"
            t.text     "scope_exclude_path_patterns"
            t.text     "scope_exclude_content_patterns"
            t.boolean  "scope_exclude_binaries"
            t.text     "scope_include_path_patterns"
            t.text     "scope_restrict_paths"
            t.text     "scope_extend_paths"
            t.integer  "scope_dom_depth_limit"
            t.integer  "scope_directory_depth_limit"

            t.text     "http_user_agent"
            t.string   "http_authentication_username"
            t.string   "http_authentication_password"

            t.text     "session_check_url"
            t.text     "session_check_pattern"

            t.integer  "browser_cluster_screen_width"
            t.integer  "browser_cluster_screen_height"

            t.timestamps
        end
    end
end
