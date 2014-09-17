class CreateProfiles < ActiveRecord::Migration
    def change
        create_table :profiles do |t|
            t.belongs_to :user
            t.belongs_to :plan, index: true
            t.boolean  "default"
            t.string   "name"
            t.text     "description"
            t.text     "scope_redundant_path_patterns"
            t.boolean  "audit_links"
            t.boolean  "audit_forms"
            t.boolean  "audit_cookies"
            t.boolean  "audit_headers"
            t.text     "checks"
            t.text     "http_cookies"
            t.text     "http_user_agent"
            t.text     "scope_exclude_path_patterns"
            t.text     "scope_exclude_content_patterns"
            t.text     "audit_exclude_vector_patterns"
            t.text     "scope_include_path_patterns"
            t.text     "http_request_headers"
            t.text     "scope_restrict_paths"
            t.text     "scope_extend_paths"
            t.boolean  "audit_with_both_http_methods"
            t.text     "session_check_url"
            t.text     "session_check_pattern"
            t.boolean  "no_fingerprinting"
            t.text     "platforms"
            t.string   "http_authentication_username"
            t.string   "http_authentication_password"
            t.text     "input_values"
            t.text     "audit_link_templates"
            t.text     "audit_include_vector_patterns"
            t.text     "scope_url_rewrites"
            t.integer  "browser_cluster_screen_width"
            t.integer  "browser_cluster_screen_height"

            t.timestamps
        end
    end
end
