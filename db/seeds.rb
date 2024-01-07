# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def scan_id
    Scan.count + 1
end

user = User.create(
    email:                 'test@stuff.com',
    password:              'testtest',
    password_confirmation: 'testtest'
)

engine_defaults  = Profile.flatten( SCNR::Engine::Options.to_rpc_data )

engine_defaults.merge!(
    name:        'Default',
    description: 'Sensible, default settings.',
    user:        user
)

# exit

# puts 'SETTING UP DEFAULT PROFILES'
# p = Profile.create! engine_defaults.merge(
#                         name:        'Default',
#                         description: 'Sensible, default settings.',
#                         checks:      :all
#                     )
# p.default!
# puts 'Default settings created: ' << p.name

Setting.create!( Setting.flatten( SCNR::Engine::Options.to_rpc_data ) )

all_checks_profile = Profile.create! engine_defaults.merge(
    name:        'All checks',
    description: 'Scans for all available security issues.',
    checks:      FrameworkHelper.checks.keys
)
puts 'All checks profile created: ' << all_checks_profile.name

p = Profile.create! engine_defaults.merge(
    name:        'DB checks',
    description: 'Scans for database injection vulnerabilities.',
    checks:      %w(no_sql_injection no_sql_injection_differential sql_injection
        sql_injection_differential sql_injection_timing)
)
puts 'SQLi profile created: ' << p.name

p = Profile.create! engine_defaults.merge(
    name:        'XSS checks',
    description: 'Scans for XSS issues.',
    checks:      %w(xss xss_dom xss_dom_script_context xss_event
        xss_path xss_script_context xss_tag xss_tag_dom)
)
puts 'XSS profile created: ' << p.name

p = Profile.create! engine_defaults.merge(
    name:        'Client-side checks',
    description: 'Scans for DOM issues like DOM XSS, unvalidated redirects etc.',
    checks:      %w(xss_dom xss_dom_script_context xss_tag_dom unvalidated_redirect_dom)
    )
puts 'Client-side profile created: ' << p.name

devices = []

devices << firefox_ua = Device.create(
    name:          'Firefox',
    device_user_agent:    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0',
    device_width:  1200,
    device_height: 1600,
    device_touch:  false,
    device_pixel_ratio:   1.0
)

devices << ie_ua = Device.create(
    name:          'Edge',
    device_user_agent:    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.2210.121',
    device_width:  1200,
    device_height: 1600,
    device_touch:  false,
    device_pixel_ratio:   1.0
)

devices << ipad_ua = Device.create(
    name:          'iPad (portrait)',
    device_user_agent:    'Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10',
    device_width:  768,
    device_height: 1024,
    device_touch:  true,
    device_pixel_ratio:   1.0
)

devices << iphone_ua = Device.create(
    name:          'iPhone (portrait)',
    device_user_agent:    'Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25',
    device_width:  320,
    device_height: 480,
    device_touch:  true,
    device_pixel_ratio:   1.0
)

puts 'Creating platforms'
SCNR::Engine::Platform::Manager::TYPES.each do |shortname, name|
    IssuePlatformType.create( shortname: shortname, name: name )
end

SCNR::Engine::Platform::Manager::PLATFORM_NAMES.each do |shortname, name|
    type = FrameworkHelper.platform_manager.find_type( shortname )
    IssuePlatformType.find_by_shortname( type ).platforms.create( shortname: shortname, name: name )
end

puts 'Creating issue types'
FrameworkHelper.framework do |f|
    f.list_checks.each do |check|
        next if !check[:issue]

        severity = IssueTypeSeverity.find_or_create_by(
            name: check[:issue][:severity].to_s
        )

        tags = []
        (check[:issue][:tags] || []).each do |tag|
            tags << IssueTypeTag.find_or_create_by( name: tag )
        end

        references = []
        (check[:issue][:references] || []).each do |title, url|
            references << IssueTypeReference.find_or_create_by(
                title: title,
                url:   url
            )
        end

        IssueType.create(
            name:            check[:issue][:name],
            description:     check[:issue][:description],
            remedy_guidance: check[:issue][:remedy_guidance],
            cwe:             check[:issue][:cwe],
            check_shortname: check[:shortname],
            severity:        severity,
            tags:            tags,
            references:      references
        )
    end
end

# exit

# site = user.sites.create!(
#     protocol: 'http',
#     host:     'testhtml5.vulnweb.com',
#     port:     80,
# )
#
# site.scans.create(
#     profile:             all_checks_profile,
#     site_role:           site.roles.first,
#     device_user_agent:          device_user_agent,
#     name:                site.url,
#     schedule_attributes: {
#         start_at: Time.now
#     }
# )
#
# site = user.sites.create(
#     protocol: 'http',
#     host:     'testfire.net',
#     port:     80,
#
#     profile_attributes: {
#         http_request_concurrency: SCNR::Engine::Options.http.request_concurrency,
#         input_values:             SCNR::Engine::Options.input.default_values.
#                                       map { |k, v| "#{k.source}=#{v}" }.join( "\n" )
#     }
# )
# site.scans.create(
#     profile:             all_checks_profile,
#     site_role:           site.roles.first,
#     device_user_agent:          device_user_agent,
#     name:                site.url,
#     schedule_attributes: {
#         start_at: Time.now
#     }
# )
#
# scans_size         = 4
# revisions_per_scan = 3
#
# sites = [
#     '/home/zapotek/workspace/scnr/engine/spec/support/fixtures/report.ser',
#     # '/home/zapotek/Downloads/testhtml5.vulnweb.com.ser',
#     # '/home/zapotek/Downloads/testfire.net.ser'
# ]
#
# sites.each.with_index do |ser, si|
#     sitemap    = nil
#     report     = SCNR::Engine::Report.load( ser )
#     parsed_url = SCNR::Engine::URI( report.url )
#     issues     = report.issues.shuffle.chunk( scans_size * revisions_per_scan )
#
#     puts 'Creating site'
#     site = user.sites.create(
#         protocol: parsed_url.scheme,
#         host:     parsed_url.host,
#         port:     parsed_url.port || 80,
#     )
#
#     site.roles.create(
#         name:                        'Administrator',
#         description:                 'Administrator account',
#         session_check_url:           site.url,
#         session_check_pattern:       'logout',
#         scope_exclude_path_patterns: ['logout'],
#         login_type:                  'form',
#         login_form_url:              "#{site.url}/admin/login",
#         login_form_parameters:       {
#             'user'     => 'admin',
#             'password' => 'secret'
#         }
#     )
#
#     site.roles.create(
#         name:                        'User',
#         description:                 'User account',
#         session_check_url:           site.url,
#         session_check_pattern:       'logout',
#         scope_exclude_path_patterns: ['logout'],
#         login_type:                  'form',
#         login_form_url:              "#{site.url}/login",
#         login_form_parameters:       {
#             'user'     => 'user',
#             'password' => 'not-so-secret'
#         }
#     )
#
#     site.reload
#     site.roles.reload
#
#     previous_scan = nil
#     scans_size.times do |i|
#         break if issues.empty?
#
#         site.scans.create(
#             profile:             p,
#             site_role:           site.roles[i % site.roles.size],
#             device:               devices.sample,
#             name:                "my scheduled scan #{scan_id}",
#             schedule_attributes: {
#                 start_at: Time.now + 3600
#             }
#         )
#
#         site.scans.create(
#             profile:             p,
#             site_role:           site.roles[i % site.roles.size],
#             device:              devices.sample,
#             name:                "my scheduled scan #{scan_id}",
#             schedule_attributes: {
#                 day_frequency:   10,
#                 month_frequency: 1
#             }
#         )
#
#         site.scans.create(
#             profile:             p,
#             site_role:           site.roles[i % site.roles.size],
#             device:              devices.sample,
#             name:                "my scheduled scan #{scan_id}",
#             schedule_attributes: {
#                 day_frequency:    1,
#                 stop_after_hours: 10
#             }
#         )
#
#         site.scans.create(
#             profile:             p,
#             site_role:           site.roles[i % site.roles.size],
#             device:              devices.sample,
#             name:                "my scheduled scan #{scan_id}",
#             schedule_attributes: {
#                 start_at:         Time.now + 3600,
#                 day_frequency:    1,
#                 month_frequency:  2,
#                 stop_after_hours: 10
#             }
#         )
#
#         s = site.scans.create(
#             profile:             p,
#             site_role:           site.roles[i % site.roles.size],
#             device:              devices.sample,
#             name:                "my scheduled scan #{scan_id}",
#             schedule_attributes: {
#                 day_frequency:    1,
#                 month_frequency:  2,
#                 stop_after_hours: 10
#             }
#         )
#         s.save
#
#         s.revisions.create(
#             status:      'finished',
#             started_at: Time.now - 8000,
#             stopped_at: Time.now - 4000
#         )
#
#         puts "[#{i}] Creating scan"
#         scan = site.scans.create(
#             profile:     p,
#             site_role:   site.roles[i % site.roles.size],
#             device:      device,
#             name:        "my scan #{scan_id}",
#             description: 'my description'
#         )
#         ap scan.errors.messages
#         scan.schedule.destroy
#         scan.save
#
#         last_revision = nil
#         revisions_per_scan.times do |j|
#             break if issues.empty?
#
#             puts "[#{i} - #{j}] Creating revision"
#             revision = scan.revisions.create(
#                 state:      'started',
#                 started_at: Time.now - 8000,
#                 stopped_at: Time.now - 4000
#             )
#
#             scan.revisions.create(
#                 state:      'started',
#                 started_at: Time.now - 8000,
#                 stopped_at: Time.now - 4000
#             )
#
#             sitemap ||= report.sitemap.each do |url, code|
#                 revision.sitemap_entries.create(
#                     url:  url,
#                     code: code
#                 )
#             end
#
#             puts "[#{i} - #{j}] Creating issues"
#             issues.pop.each do |issue|
#                 issue.variations.each do |variation|
#                     ap issue.unique_id
#                     ap issue.variations.first.page.dom.url
#
#                     solo = variation.to_solo( issue )
#
#                     next if !solo.check
#
#                     if previous_scan = site.scans.all.find { |s| s != scan }
#                         ap previous_scan.id
#                         ap scan.id
#
#                         prev_scan_revision = previous_scan.revisions.create(
#                             state:      'started',
#                             started_at: Time.now - 8000,
#                             stopped_at: Time.now - 4000
#                         )
#
#                         prev_scan_revision.issues.create_from_engine(
#                             solo,
#                             state: Issue::STATES.sample
#                         )
#                     end
#
#                     is = revision.issues.create_from_engine(
#                         solo,
#                         state: Issue::STATES.sample
#                     )
#                     ap is.errors.messages
#
#                     break
#                 end
#
#                 # ap sitemap_entry.reload.issues.size
#             end
#
#             if last_revision
#                 last_revision.issues.each do |iss|
#                     next if iss.state != 'fixed'
#
#                     iss.fixed_by_revision = revision
#                     iss.save
#                     ap iss.errors.messages
#                 end
#             end
#
#             last_revision = revision
#         end
#
#         scan.revisions.create(
#             state:      'started',
#             started_at: Time.now - 8000
#         )
#     end
# end
