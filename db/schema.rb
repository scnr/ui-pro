# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150406191208) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "http_requests", force: true do |t|
    t.text     "url"
    t.string   "http_method"
    t.text     "parameters"
    t.text     "headers"
    t.text     "body"
    t.text     "raw"
    t.integer  "requestable_id"
    t.string   "requestable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "http_requests", ["requestable_id", "requestable_type"], name: "index_http_requests_on_requestable_id_and_requestable_type"
  add_index "http_requests", ["url"], name: "index_http_requests_on_url"

  create_table "http_responses", force: true do |t|
    t.text     "url"
    t.integer  "code"
    t.string   "ip_address"
    t.text     "headers"
    t.text     "body"
    t.float    "time"
    t.string   "return_code"
    t.string   "return_message"
    t.text     "raw_headers"
    t.integer  "responsable_id"
    t.string   "responsable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "http_responses", ["responsable_id", "responsable_type"], name: "index_http_responses_on_responsable_id_and_responsable_type"
  add_index "http_responses", ["url"], name: "index_http_responses_on_url"

  create_table "issue_page_dom_data_flow_sinks", force: true do |t|
    t.text     "object"
    t.integer  "tainted_argument_index"
    t.text     "tainted_value"
    t.text     "taint_value"
    t.integer  "issue_page_dom_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_dom_data_flow_sinks", ["issue_page_dom_id"], name: "index_issue_page_dom_data_flow_sinks_on_issue_page_dom_id"
  add_index "issue_page_dom_data_flow_sinks", ["object"], name: "index_issue_page_dom_data_flow_sinks_on_object"

  create_table "issue_page_dom_execution_flow_sinks", force: true do |t|
    t.text     "data"
    t.integer  "issue_page_dom_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_dom_execution_flow_sinks", ["issue_page_dom_id"], name: "index_issue_page_dom_execution_flow_sinks_on_issue_page_dom_id"

  create_table "issue_page_dom_functions", force: true do |t|
    t.text     "source"
    t.text     "arguments"
    t.text     "name"
    t.integer  "with_dom_function_id"
    t.string   "with_dom_function_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_dom_functions", ["name"], name: "index_issue_page_dom_functions_on_name"
  add_index "issue_page_dom_functions", ["with_dom_function_id", "with_dom_function_type"], name: "issue_page_dom_functions_poly_index"

  create_table "issue_page_dom_stack_frames", force: true do |t|
    t.integer  "line"
    t.text     "url"
    t.integer  "with_dom_stack_frame_id"
    t.string   "with_dom_stack_frame_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_dom_stack_frames", ["with_dom_stack_frame_id", "with_dom_stack_frame_type"], name: "issue_page_dom_stack_frames_poly_index"

  create_table "issue_page_dom_transitions", force: true do |t|
    t.text     "element"
    t.text     "event"
    t.text     "options"
    t.float    "time"
    t.integer  "issue_page_dom_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_dom_transitions", ["issue_page_dom_id"], name: "index_issue_page_dom_transitions_on_issue_page_dom_id"

  create_table "issue_page_doms", force: true do |t|
    t.string   "url"
    t.text     "body"
    t.integer  "issue_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_doms", ["issue_page_id"], name: "index_issue_page_doms_on_issue_page_id"
  add_index "issue_page_doms", ["url"], name: "index_issue_page_doms_on_url"

  create_table "issue_pages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issue_platform_types", force: true do |t|
    t.string   "shortname"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_platform_types", ["name"], name: "index_issue_platform_types_on_name", unique: true
  add_index "issue_platform_types", ["shortname"], name: "index_issue_platform_types_on_shortname", unique: true

  create_table "issue_platforms", force: true do |t|
    t.string   "shortname"
    t.string   "name"
    t.integer  "issue_platform_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_platforms", ["issue_platform_type_id"], name: "index_issue_platforms_on_issue_platform_type_id"
  add_index "issue_platforms", ["name"], name: "index_issue_platforms_on_name", unique: true
  add_index "issue_platforms", ["shortname"], name: "index_issue_platforms_on_shortname", unique: true

  create_table "issue_remarks", force: true do |t|
    t.string   "author"
    t.text     "text"
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_remarks", ["issue_id"], name: "index_issue_remarks_on_issue_id"

  create_table "issue_type_references", force: true do |t|
    t.string   "title"
    t.text     "url"
    t.integer  "issue_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_type_references", ["issue_type_id"], name: "index_issue_type_references_on_issue_type_id"

  create_table "issue_type_severities", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_type_severities", ["name"], name: "index_issue_type_severities_on_name", unique: true

  create_table "issue_type_tags", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_type_tags", ["name"], name: "index_issue_type_tags_on_name", unique: true

  create_table "issue_types", force: true do |t|
    t.string   "name"
    t.string   "check_shortname"
    t.text     "description"
    t.text     "remedy_guidance"
    t.integer  "cwe"
    t.integer  "issue_type_severity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_types", ["check_shortname"], name: "index_issue_types_on_check_shortname", unique: true
  add_index "issue_types", ["issue_type_severity_id"], name: "index_issue_types_on_issue_type_severity_id"
  add_index "issue_types", ["name"], name: "index_issue_types_on_name", unique: true

  create_table "issue_types_issue_type_tags", force: true do |t|
    t.integer "issue_type_id"
    t.integer "issue_type_tag_id"
  end

  create_table "issues", force: true do |t|
    t.string   "digest"
    t.text     "signature"
    t.text     "proof"
    t.boolean  "trusted"
    t.boolean  "active"
    t.integer  "referring_issue_page_id"
    t.integer  "revision_id"
    t.integer  "issue_page_id"
    t.integer  "issue_type_id"
    t.integer  "issue_platform_id"
    t.integer  "sitemap_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues", ["active"], name: "index_issues_on_active"
  add_index "issues", ["digest"], name: "index_issues_on_digest"
  add_index "issues", ["issue_page_id"], name: "index_issues_on_issue_page_id"
  add_index "issues", ["issue_platform_id"], name: "index_issues_on_issue_platform_id"
  add_index "issues", ["issue_type_id"], name: "index_issues_on_issue_type_id"
  add_index "issues", ["referring_issue_page_id"], name: "index_issues_on_referring_issue_page_id"
  add_index "issues", ["revision_id"], name: "index_issues_on_revision_id"
  add_index "issues", ["sitemap_entry_id"], name: "index_issues_on_sitemap_entry_id"
  add_index "issues", ["trusted"], name: "index_issues_on_trusted"

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: true do |t|
    t.integer  "revision_id"
    t.text     "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["revision_id"], name: "index_reports_on_revision_id"

  create_table "revisions", force: true do |t|
    t.integer  "scan_id"
    t.string   "state"
    t.integer  "index"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.string   "snapshot_location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revisions", ["scan_id"], name: "index_revisions_on_scan_id"

  create_table "scans", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "revisions_count", default: 0
    t.integer  "integer",         default: 0
    t.integer  "site_id"
    t.integer  "user_agent_id"
    t.integer  "site_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
  end

  add_index "scans", ["profile_id"], name: "index_scans_on_profile_id"
  add_index "scans", ["site_id"], name: "index_scans_on_site_id"

  create_table "schedules", force: true do |t|
    t.integer  "month_frequency"
    t.integer  "day_frequency"
    t.datetime "start_at"
    t.float    "stop_after_hours"
    t.boolean  "stop_suspend"
    t.integer  "scan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["scan_id"], name: "index_schedules_on_scan_id"

  create_table "settings", force: true do |t|
    t.integer  "http_request_timeout"
    t.integer  "http_request_queue_size"
    t.integer  "http_request_redirect_limit"
    t.integer  "http_response_max_size"
    t.string   "http_proxy_host"
    t.integer  "http_proxy_port"
    t.string   "http_proxy_username"
    t.string   "http_proxy_password"
    t.integer  "browser_cluster_pool_size"
    t.integer  "browser_cluster_job_timeout"
    t.integer  "browser_cluster_worker_time_to_live"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_profiles", force: true do |t|
    t.text     "platforms"
    t.boolean  "no_fingerprinting"
    t.text     "input_values"
    t.text     "audit_link_templates"
    t.text     "scope_redundant_path_patterns"
    t.integer  "scope_auto_redundant_paths"
    t.text     "scope_url_rewrites"
    t.boolean  "scope_https_only"
    t.boolean  "scope_include_subdomains"
    t.text     "http_cookies"
    t.text     "http_request_headers"
    t.integer  "http_request_concurrency"
    t.string   "http_authentication_username"
    t.string   "http_authentication_password"
    t.boolean  "browser_cluster_ignore_images"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_profiles", ["site_id"], name: "index_site_profiles_on_site_id"

  create_table "site_roles", force: true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.text     "description"
    t.text     "session_check_url"
    t.text     "session_check_pattern"
    t.text     "scope_exclude_path_patterns"
    t.string   "login_type"
    t.text     "login_form_url"
    t.text     "login_form_parameters"
    t.text     "login_script_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sitemap_entries", force: true do |t|
    t.text     "url"
    t.integer  "code"
    t.integer  "issues_count", default: 0
    t.integer  "integer",      default: 0
    t.integer  "site_id"
    t.integer  "revision_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sitemap_entries", ["revision_id"], name: "index_sitemap_entries_on_revision_id"
  add_index "sitemap_entries", ["site_id"], name: "index_sitemap_entries_on_site_id"
  add_index "sitemap_entries", ["url", "site_id"], name: "index_sitemap_entries_on_url_and_site_id", unique: true

  create_table "sites", force: true do |t|
    t.integer  "protocol"
    t.string   "host"
    t.integer  "port",       default: 80
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["protocol", "host", "port"], name: "index_sites_on_protocol_and_host_and_port"
  add_index "sites", ["user_id"], name: "index_sites_on_user_id"

  create_table "sites_users", id: false, force: true do |t|
    t.integer "site_id"
    t.integer "user_id"
  end

  add_index "sites_users", ["site_id", "user_id"], name: "index_sites_users_on_site_id_and_user_id"
  add_index "sites_users", ["user_id"], name: "index_sites_users_on_user_id"

  create_table "user_agents", force: true do |t|
    t.boolean  "default"
    t.string   "name"
    t.text     "http_user_agent"
    t.integer  "browser_cluster_screen_width"
    t.integer  "browser_cluster_screen_height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "unique_session_id",      limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "vectors", force: true do |t|
    t.text     "default_inputs"
    t.text     "inputs"
    t.text     "seed"
    t.string   "arachni_class"
    t.string   "kind"
    t.text     "action"
    t.text     "source"
    t.string   "http_method"
    t.text     "affected_input_name"
    t.integer  "with_vector_id"
    t.string   "with_vector_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vectors", ["kind"], name: "index_vectors_on_kind"
  add_index "vectors", ["with_vector_id", "with_vector_type"], name: "index_vectors_on_with_vector_id_and_with_vector_type"

end
