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

ActiveRecord::Schema.define(version: 20140919034058) do

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

  create_table "global_profiles", force: true do |t|
    t.integer  "scope_directory_depth_limit"
    t.integer  "http_request_redirect_limit"
    t.integer  "http_request_concurrency"
    t.integer  "http_response_max_size"
    t.boolean  "scope_include_subdomains"
    t.text     "plugins"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "issue_page_dom_execution_flow_sinks", force: true do |t|
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

  create_table "issue_page_doms", force: true do |t|
    t.string   "url"
    t.text     "body"
    t.integer  "issue_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_page_doms", ["issue_page_id"], name: "index_issue_page_doms_on_issue_page_id"

  create_table "issue_pages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "price"
    t.integer  "profile_id"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_overrides", force: true do |t|
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
    t.boolean  "scope_exclude_binaries"
    t.integer  "scope_auto_redundant_paths"
    t.boolean  "scope_https_only"
    t.text     "session_check_url"
    t.text     "session_check_pattern"
    t.integer  "http_request_timeout"
    t.boolean  "no_fingerprinting"
    t.text     "platforms"
    t.string   "http_authentication_username"
    t.string   "http_authentication_password"
    t.integer  "http_request_queue_size"
    t.text     "input_values"
    t.text     "audit_link_templates"
    t.text     "audit_include_vector_patterns"
    t.text     "scope_url_rewrites"
    t.integer  "scope_dom_depth_limit"
    t.integer  "browser_cluster_pool_size"
    t.integer  "browser_cluster_job_timeout"
    t.integer  "browser_cluster_worker_time_to_live"
    t.boolean  "browser_cluster_ignore_images"
    t.integer  "browser_cluster_screen_width"
    t.integer  "browser_cluster_screen_height"
    t.integer  "scope_directory_depth_limit"
    t.integer  "http_request_redirect_limit"
    t.integer  "http_request_concurrency"
    t.integer  "http_response_max_size"
    t.boolean  "scope_include_subdomains"
    t.text     "plugins"
    t.integer  "scope_page_limit"
    t.integer  "profile_overridable_id"
    t.string   "profile_overridable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["plan_id"], name: "index_profiles_on_plan_id"

  create_table "revisions", force: true do |t|
    t.integer  "scan_id"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.string   "snapshot_location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revisions", ["scan_id"], name: "index_revisions_on_scan_id"

  create_table "scans", force: true do |t|
    t.integer  "site_id"
    t.integer  "plan_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
  end

  add_index "scans", ["plan_id"], name: "index_scans_on_plan_id"
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

  create_table "site_verifications", force: true do |t|
    t.string   "filename"
    t.string   "state",      default: "pending"
    t.text     "code"
    t.text     "message"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", force: true do |t|
    t.string   "protocol",   default: "http"
    t.string   "host"
    t.integer  "port",       default: 80
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites_users", id: false, force: true do |t|
    t.integer "site_id"
    t.integer "user_id"
  end

  add_index "sites_users", ["site_id", "user_id"], name: "index_sites_users_on_site_id_and_user_id"
  add_index "sites_users", ["user_id"], name: "index_sites_users_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
