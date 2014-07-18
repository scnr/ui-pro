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

ActiveRecord::Schema.define(version: 20140716021611) do

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.boolean  "default"
    t.string   "name"
    t.text     "description"
    t.text     "scope_redundant_path_patterns"
    t.integer  "scope_directory_depth_limit"
    t.integer  "scope_page_limit"
    t.integer  "http_request_redirect_limit"
    t.integer  "http_request_concurrency"
    t.boolean  "audit_links"
    t.boolean  "audit_forms"
    t.boolean  "audit_cookies"
    t.boolean  "audit_headers"
    t.text     "checks"
    t.text     "authorized_by"
    t.string   "http_proxy_host"
    t.integer  "http_proxy_port"
    t.string   "http_proxy_username"
    t.text     "http_proxy_password"
    t.string   "http_proxy_type"
    t.text     "http_cookies"
    t.text     "http_user_agent"
    t.text     "scope_exclude_path_patterns"
    t.text     "scope_exclude_content_patterns"
    t.text     "audit_exclude_vector_patterns"
    t.text     "scope_include_path_patterns"
    t.boolean  "scope_include_subdomains"
    t.text     "plugins"
    t.text     "http_request_headers"
    t.text     "scope_restrict_paths"
    t.text     "scope_extend_paths"
    t.boolean  "audit_with_both_http_methods"
    t.boolean  "audit_cookies_extensively"
    t.boolean  "scope_exclude_binaries"
    t.integer  "scope_auto_redundant_paths"
    t.boolean  "scope_https_only"
    t.text     "login_check_url"
    t.text     "login_check_pattern"
    t.integer  "http_request_timeout"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "scans", force: true do |t|
    t.integer  "site_id"
    t.boolean  "enabled",     default: false
    t.string   "name"
    t.text     "description"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scans", ["site_id"], name: "index_scans_on_site_id"

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
