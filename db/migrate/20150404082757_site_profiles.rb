class SiteProfiles < ActiveRecord::Migration[5.1]
    def change
        create_table :site_profiles do |t|
            t.integer  :max_parallel_scans, default: 1
            t.binary     :platforms
            t.boolean  :no_fingerprinting

            t.binary     :input_values

            t.binary     :audit_link_templates

            t.binary     :scope_exclude_file_extensions
            t.binary     :scope_exclude_path_patterns
            t.binary     :scope_exclude_content_patterns
            t.binary     :scope_extend_paths
            t.binary     :scope_template_path_patterns
            t.integer  :scope_auto_redundant_paths
            t.binary     :scope_url_rewrites
            t.boolean  :scope_https_only
            t.boolean  :scope_include_subdomains

            t.binary     :http_cookies
            t.binary     :http_request_headers
            t.integer  :http_request_concurrency
            t.string   :http_authentication_username, default: ''
            t.string   :http_authentication_password, default: ''

            t.binary     :browser_cluster_wait_for_elements

            t.belongs_to :site, index: true

            # Frozen copy at the time of Revision creation.
            t.belongs_to :revision

            t.timestamps
        end
    end
end
