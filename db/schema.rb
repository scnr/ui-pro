# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_15_100000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "devices", force: :cascade do |t|
    t.boolean "default"
    t.string "name"
    t.text "device_user_agent"
    t.integer "device_width"
    t.integer "device_height"
    t.boolean "device_touch"
    t.float "device_pixel_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "http_requests", force: :cascade do |t|
    t.text "url"
    t.string "http_method"
    t.binary "parameters"
    t.binary "headers"
    t.binary "body"
    t.binary "raw"
    t.string "requestable_type"
    t.bigint "requestable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requestable_type", "requestable_id"], name: "index_http_requests_on_requestable"
    t.index ["url"], name: "index_http_requests_on_url"
  end

  create_table "http_responses", force: :cascade do |t|
    t.text "url"
    t.integer "code"
    t.string "ip_address"
    t.binary "headers"
    t.binary "body"
    t.float "time"
    t.string "return_code"
    t.text "return_message"
    t.binary "raw_headers"
    t.string "responsable_type"
    t.bigint "responsable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["responsable_type", "responsable_id"], name: "index_http_responses_on_responsable"
    t.index ["url"], name: "index_http_responses_on_url"
  end

  create_table "input_vectors", force: :cascade do |t|
    t.binary "default_inputs"
    t.binary "inputs"
    t.text "seed"
    t.string "engine_class"
    t.string "kind"
    t.text "action"
    t.text "source"
    t.string "http_method"
    t.text "affected_input_name"
    t.bigint "sitemap_entry_id"
    t.bigint "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_input_vectors_on_issue_id"
    t.index ["kind"], name: "index_input_vectors_on_kind"
    t.index ["sitemap_entry_id"], name: "index_input_vectors_on_sitemap_entry_id"
  end

  create_table "issue_page_dom_data_flow_sinks", force: :cascade do |t|
    t.text "object"
    t.integer "tainted_argument_index"
    t.binary "tainted_value"
    t.binary "taint_value"
    t.bigint "issue_page_dom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_page_dom_id"], name: "index_issue_page_dom_data_flow_sinks_on_issue_page_dom_id"
    t.index ["object"], name: "index_issue_page_dom_data_flow_sinks_on_object"
  end

  create_table "issue_page_dom_execution_flow_sinks", force: :cascade do |t|
    t.binary "data"
    t.bigint "issue_page_dom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_page_dom_id"], name: "index_issue_page_dom_execution_flow_sinks_on_issue_page_dom_id"
  end

  create_table "issue_page_dom_functions", force: :cascade do |t|
    t.binary "source"
    t.binary "arguments"
    t.text "name"
    t.string "with_dom_function_type"
    t.bigint "with_dom_function_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_issue_page_dom_functions_on_name"
    t.index ["with_dom_function_type", "with_dom_function_id"], name: "issue_page_dom_functions_poly_index"
  end

  create_table "issue_page_dom_stack_frames", force: :cascade do |t|
    t.integer "line"
    t.text "url"
    t.string "with_dom_stack_frame_type"
    t.bigint "with_dom_stack_frame_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["with_dom_stack_frame_type", "with_dom_stack_frame_id"], name: "issue_page_dom_stack_frames_poly_index"
  end

  create_table "issue_page_dom_transitions", force: :cascade do |t|
    t.binary "element"
    t.text "event"
    t.binary "options"
    t.float "time"
    t.bigint "issue_page_dom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_page_dom_id"], name: "index_issue_page_dom_transitions_on_issue_page_dom_id"
  end

  create_table "issue_page_doms", force: :cascade do |t|
    t.text "url"
    t.binary "body"
    t.bigint "issue_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_page_id"], name: "index_issue_page_doms_on_issue_page_id"
    t.index ["url"], name: "index_issue_page_doms_on_url"
  end

  create_table "issue_pages", force: :cascade do |t|
    t.bigint "sitemap_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sitemap_entry_id"], name: "index_issue_pages_on_sitemap_entry_id"
  end

  create_table "issue_platform_types", force: :cascade do |t|
    t.string "shortname"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_issue_platform_types_on_name", unique: true
    t.index ["shortname"], name: "index_issue_platform_types_on_shortname", unique: true
  end

  create_table "issue_platforms", force: :cascade do |t|
    t.string "shortname"
    t.string "name"
    t.bigint "issue_platform_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_platform_type_id"], name: "index_issue_platforms_on_issue_platform_type_id"
    t.index ["name"], name: "index_issue_platforms_on_name", unique: true
    t.index ["shortname"], name: "index_issue_platforms_on_shortname", unique: true
  end

  create_table "issue_remarks", force: :cascade do |t|
    t.string "author"
    t.text "text"
    t.bigint "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_issue_remarks_on_issue_id"
  end

  create_table "issue_type_references", force: :cascade do |t|
    t.string "title"
    t.text "url"
    t.bigint "issue_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_type_id"], name: "index_issue_type_references_on_issue_type_id"
  end

  create_table "issue_type_severities", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_issue_type_severities_on_name", unique: true
  end

  create_table "issue_type_tags", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_issue_type_tags_on_name", unique: true
  end

  create_table "issue_types", force: :cascade do |t|
    t.string "name"
    t.string "check_shortname"
    t.text "description"
    t.text "remedy_guidance"
    t.integer "cwe"
    t.bigint "issue_type_severity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_shortname"], name: "index_issue_types_on_check_shortname", unique: true
    t.index ["issue_type_severity_id"], name: "index_issue_types_on_issue_type_severity_id"
    t.index ["name"], name: "index_issue_types_on_name", unique: true
  end

  create_table "issue_types_issue_type_tags", force: :cascade do |t|
    t.integer "issue_type_id"
    t.integer "issue_type_tag_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "digest"
    t.string "state"
    t.boolean "active"
    t.binary "proof"
    t.binary "signature"
    t.integer "referring_issue_page_id"
    t.integer "reviewed_by_revision_id"
    t.bigint "revision_id"
    t.bigint "scan_id"
    t.bigint "site_id"
    t.bigint "issue_page_id"
    t.bigint "issue_type_id"
    t.bigint "issue_platform_id"
    t.bigint "sitemap_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_issues_on_active"
    t.index ["digest"], name: "index_issues_on_digest"
    t.index ["issue_page_id"], name: "index_issues_on_issue_page_id"
    t.index ["issue_platform_id"], name: "index_issues_on_issue_platform_id"
    t.index ["issue_type_id"], name: "index_issues_on_issue_type_id"
    t.index ["referring_issue_page_id"], name: "index_issues_on_referring_issue_page_id"
    t.index ["revision_id"], name: "index_issues_on_revision_id"
    t.index ["scan_id"], name: "index_issues_on_scan_id"
    t.index ["site_id"], name: "index_issues_on_site_id"
    t.index ["sitemap_entry_id"], name: "index_issues_on_sitemap_entry_id"
    t.index ["state"], name: "index_issues_on_state"
  end

  create_table "performance_snapshots", force: :cascade do |t|
    t.integer "http_request_count"
    t.integer "http_response_count"
    t.integer "http_time_out_count"
    t.float "http_average_responses_per_second"
    t.float "http_average_response_time"
    t.integer "http_max_concurrency"
    t.integer "http_original_max_concurrency"
    t.float "runtime"
    t.integer "page_count"
    t.text "current_page"
    t.integer "revision_current_id"
    t.bigint "revision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_current_id"], name: "index_performance_snapshots_on_revision_current_id"
    t.index ["revision_id"], name: "index_performance_snapshots_on_revision_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "default"
    t.string "name"
    t.text "description"
    t.binary "checks"
    t.binary "plugins"
    t.boolean "audit_links"
    t.boolean "audit_forms"
    t.boolean "audit_cookies"
    t.boolean "audit_cookies_extensively"
    t.boolean "audit_headers"
    t.boolean "audit_jsons"
    t.boolean "audit_xmls"
    t.boolean "audit_ui_forms"
    t.boolean "audit_ui_inputs"
    t.boolean "audit_parameter_names"
    t.boolean "audit_with_extra_parameter"
    t.boolean "audit_with_both_http_methods"
    t.binary "audit_exclude_vector_patterns"
    t.binary "audit_include_vector_patterns"
    t.integer "scope_page_limit"
    t.binary "scope_exclude_path_patterns"
    t.binary "scope_exclude_content_patterns"
    t.boolean "scope_exclude_binaries"
    t.binary "scope_include_path_patterns"
    t.integer "scope_dom_depth_limit"
    t.integer "scope_directory_depth_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "revision_id"
    t.text "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_id"], name: "index_reports_on_revision_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.bigint "scan_id"
    t.bigint "site_id"
    t.integer "index"
    t.binary "rpc_options"
    t.text "snapshot_path"
    t.text "error_messages"
    t.string "seed"
    t.string "status"
    t.boolean "timed_out", default: false
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.integer "issues_count", default: 0
    t.integer "sitemap_entries_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scan_id"], name: "index_revisions_on_scan_id"
    t.index ["site_id"], name: "index_revisions_on_site_id"
  end

  create_table "scans", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "path"
    t.string "status"
    t.boolean "timed_out", default: false
    t.integer "revisions_count", default: 0
    t.integer "issues_count", default: 0
    t.integer "sitemap_entries_count", default: 0
    t.bigint "site_id"
    t.bigint "device_id"
    t.bigint "site_role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id"
    t.index ["device_id"], name: "index_scans_on_device_id"
    t.index ["profile_id"], name: "index_scans_on_profile_id"
    t.index ["site_id"], name: "index_scans_on_site_id"
    t.index ["site_role_id"], name: "index_scans_on_site_role_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "month_frequency"
    t.integer "day_frequency"
    t.string "frequency_base"
    t.text "frequency_cron"
    t.string "frequency_format"
    t.datetime "start_at"
    t.float "stop_after_hours"
    t.boolean "stop_suspend"
    t.bigint "scan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scan_id"], name: "index_schedules_on_scan_id"
  end

  create_table "settings", force: :cascade do |t|
    t.integer "http_request_timeout"
    t.integer "http_request_queue_size"
    t.integer "http_request_redirect_limit"
    t.integer "http_response_max_size"
    t.string "http_proxy_host"
    t.integer "http_proxy_port"
    t.string "http_proxy_username"
    t.string "http_proxy_password"
    t.integer "dom_pool_size"
    t.integer "dom_job_timeout"
    t.integer "dom_worker_time_to_live"
    t.integer "max_parallel_scans"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_profiles", force: :cascade do |t|
    t.integer "max_parallel_scans", default: 1
    t.binary "platforms"
    t.boolean "no_fingerprinting"
    t.binary "input_values"
    t.binary "audit_link_templates"
    t.binary "scope_exclude_file_extensions"
    t.binary "scope_exclude_path_patterns"
    t.binary "scope_exclude_content_patterns"
    t.binary "scope_extend_paths"
    t.binary "scope_template_path_patterns"
    t.integer "scope_auto_redundant_paths"
    t.binary "scope_url_rewrites"
    t.boolean "scope_https_only"
    t.boolean "scope_include_subdomains"
    t.binary "http_cookies"
    t.binary "http_request_headers"
    t.integer "http_request_concurrency"
    t.string "http_authentication_username", default: ""
    t.string "http_authentication_password", default: ""
    t.binary "dom_wait_for_elements"
    t.bigint "site_id"
    t.bigint "revision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_id"], name: "index_site_profiles_on_revision_id"
    t.index ["site_id"], name: "index_site_profiles_on_site_id"
  end

  create_table "site_roles", force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "revision_id"
    t.string "name"
    t.text "description"
    t.text "session_check_url"
    t.text "session_check_pattern"
    t.binary "scope_exclude_path_patterns"
    t.string "login_type"
    t.text "login_form_url"
    t.binary "login_form_parameters"
    t.text "login_script_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_id"], name: "index_site_roles_on_revision_id"
    t.index ["site_id"], name: "index_site_roles_on_site_id"
  end

  create_table "sitemap_entries", force: :cascade do |t|
    t.boolean "coverage"
    t.text "url"
    t.integer "code"
    t.integer "issues_count", default: 0
    t.integer "issue_pages_count", default: 0
    t.integer "input_vectors_count", default: 0
    t.bigint "digest"
    t.bigint "site_id"
    t.bigint "scan_id"
    t.bigint "revision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["digest", "revision_id"], name: "index_sitemap_entries_on_digest_and_revision_id", unique: true
    t.index ["digest"], name: "index_sitemap_entries_on_digest"
    t.index ["revision_id"], name: "index_sitemap_entries_on_revision_id"
    t.index ["scan_id"], name: "index_sitemap_entries_on_scan_id"
    t.index ["site_id"], name: "index_sitemap_entries_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.integer "protocol"
    t.string "host"
    t.integer "port", default: 80
    t.integer "scans_count", default: 0
    t.integer "revisions_count", default: 0
    t.integer "issues_count", default: 0
    t.integer "sitemap_entries_count", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol", "host", "port"], name: "index_sites_on_protocol_and_host_and_port"
    t.index ["user_id"], name: "index_sites_on_user_id"
  end

  create_table "sites_users", id: false, force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "user_id"
    t.index ["site_id", "user_id"], name: "index_sites_users_on_site_id_and_user_id"
    t.index ["site_id"], name: "index_sites_users_on_site_id"
    t.index ["user_id"], name: "index_sites_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "unique_session_id", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.integer "site_id"
    t.integer "scan_id"
    t.integer "revision_id"
    t.text "object_to_s"
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["revision_id"], name: "index_versions_on_revision_id"
    t.index ["scan_id"], name: "index_versions_on_scan_id"
    t.index ["site_id"], name: "index_versions_on_site_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
