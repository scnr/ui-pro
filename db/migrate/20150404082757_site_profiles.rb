class SiteProfiles < ActiveRecord::Migration
    def change
        create_table :site_profiles do |t|
            t.text     :platforms
            t.boolean  :no_fingerprinting

            t.text     :input_values

            t.text     :audit_link_templates

            t.text     :scope_extend_paths
            t.text     :scope_template_path_patterns
            t.integer  :scope_auto_redundant_paths
            t.text     :scope_url_rewrites
            t.boolean  :scope_https_only
            t.boolean  :scope_include_subdomains

            t.text     :http_cookies
            t.text     :http_request_headers
            t.integer  :http_request_concurrency
            t.string   :http_authentication_username
            t.string   :http_authentication_password

            t.boolean  :browser_cluster_ignore_images
            t.text     :browser_cluster_wait_for_elements

            t.belongs_to :site, index: true

            t.timestamps
        end
    end
end
