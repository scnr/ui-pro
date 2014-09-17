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

ActiveRecord::Schema.define(version: 20140917174338) do

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
