class CreateDefaultProfiles < ActiveRecord::Migration
  def change
      create_table :default_profiles do |t|
          t.integer  "scope_directory_depth_limit"
          t.integer  "http_request_redirect_limit"
          t.integer  "http_request_concurrency"
          t.integer  "http_response_max_size"
          t.boolean  "scope_include_subdomains"
          t.text     "plugins"
          t.boolean  "audit_with_both_http_methods"
          t.boolean  "scope_exclude_binaries"
          t.integer  "scope_auto_redundant_paths"
          t.boolean  "scope_https_only"
          t.integer  "http_request_timeout"
          t.integer  "http_request_queue_size"
          t.integer  "scope_dom_depth_limit"
          t.integer  "browser_cluster_pool_size"
          t.integer  "browser_cluster_job_timeout"
          t.integer  "browser_cluster_worker_time_to_live"
          t.boolean  "browser_cluster_ignore_images"

          t.timestamps
      end
  end
end
