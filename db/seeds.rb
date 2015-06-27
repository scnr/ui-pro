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

arachni_defaults = {}
ap profile_columns  = Profile.column_names

Arachni::Options.to_rpc_data.each do |name, value|
    name = name.to_sym
    next if value.nil?

    if Arachni::Options.group_classes.include?( name )
        value.each do |k, v|
            next if v.nil?

            key = "#{name}_#{k}".to_sym
            if !profile_columns.include?( key.to_s )
                $stderr.puts "[Profile defaults] Ignoring: #{key}"
                next
            end

            arachni_defaults[key] = v
        end
    else
        if !profile_columns.include?( name.to_s )
            $stderr.puts "[Profile defaults] Ignoring: #{name}"
            next
        end
        arachni_defaults[name] = value
    end
end

arachni_defaults.merge!(
    name:          'Default',
    description:   'Sensible, default settings.',
    user:          user,
    audit_links:   true,
    audit_forms:   true,
    audit_cookies: true
)

# exit

# puts 'SETTING UP DEFAULT PROFILES'
# p = Profile.create! arachni_defaults.merge(
#                         name:        'Default',
#                         description: 'Sensible, default settings.',
#                         checks:      :all
#                     )
# p.default!
# puts 'Default profile created: ' << p.name

Setting.create!(
    http_request_timeout: Arachni::Options.http.request_timeout
)

p = Profile.create! arachni_defaults.merge(
    name:        'Cross-Site Scripting (XSS)',
    description: 'Scans for Cross-Site Scripting (XSS) vulnerabilities.',
    checks:      %w(xss xss_path xss_tag xss_script_context xss_event
                    xss_dom xss_dom_inputs xss_dom_script_context)
)
puts 'XSS profile created: ' << p.name

p = Profile.create! arachni_defaults.merge(
    name:        'SQL injection',
    description: 'Scans for SQL injection vulnerabilities.',
    checks:      %w(sql_injection sql_injection_differential sql_injection_timing)
)
puts 'SQLi profile created: ' << p.name

puts 'Creating platforms'
Arachni::Platform::Manager::TYPES.each do |shortname, name|
    IssuePlatformType.create( shortname: shortname, name: name )
end

Arachni::Platform::Manager::PLATFORM_NAMES.each do |shortname, name|
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

user_agent = UserAgent.create(
    name: 'Arachni',
    http_user_agent: Arachni::Options.http.user_agent,
    browser_cluster_screen_width:  1200,
    browser_cluster_screen_height: 1600
)

scans_size         = 4
revisions_per_scan = 3

sites = [
    # '/home/zapotek/workspace/arachni/spec/support/fixtures/report.afr',
    '/home/zapotek/Downloads/testhtml5.vulnweb.com.afr',
    '/home/zapotek/Downloads/testfire.net.afr'
]

sites.each.with_index do |afr, si|
    sitemap    = nil
    report     = Arachni::Report.load( afr )
    parsed_url = Arachni::URI( report.url )
    issues     = report.issues.shuffle.chunk( scans_size * revisions_per_scan )

    puts 'Creating site'
    site = user.sites.create(
        protocol: parsed_url.scheme,
        host:     parsed_url.host,
        port:     parsed_url.port || 80,

        profile_attributes: {
            http_request_concurrency: Arachni::Options.http.request_concurrency,
            input_values:             Arachni::Options.input.default_values.
                                        map { |k, v| "#{k.source}=#{v}" }.join( "\n" )
        }
    )

    site.roles.create(
        name:                        'Administrator',
        description:                 'Administrator account',
        session_check_url:           site.url,
        session_check_pattern:       'logout',
        scope_exclude_path_patterns: ['logout'],
        login_type:                  'form',
        login_form_url:              "#{site.url}/admin/login",
        login_form_parameters:       {
            'user'     => 'admin',
            'password' => 'secret'
        }
    )

    site.roles.create(
        name:                        'User',
        description:                 'User account',
        session_check_url:           site.url,
        session_check_pattern:       'logout',
        scope_exclude_path_patterns: ['logout'],
        login_type:                  'form',
        login_form_url:              "#{site.url}/login",
        login_form_parameters:       {
            'user'     => 'user',
            'password' => 'not-so-secret'
        }
    )

    site.reload
    site.roles.reload

    previous_scan = nil
    scans_size.times do |i|
        break if issues.empty?

        site.scans.create(
            profile:             p,
            site_role:           site.roles[i % site.roles.size],
            user_agent:          user_agent,
            name:                "my scheduled scan #{scan_id}",
            schedule_attributes: {
                start_at: Time.now + 3600
            }
        )

        site.scans.create(
            profile:             p,
            site_role:           site.roles[i % site.roles.size],
            user_agent:          user_agent,
            name:                "my scheduled scan #{scan_id}",
            schedule_attributes: {
                day_frequency:   10,
                month_frequency: 1
            }
        )

        site.scans.create(
            profile:             p,
            site_role:           site.roles[i % site.roles.size],
            user_agent:          user_agent,
            name:                "my scheduled scan #{scan_id}",
            schedule_attributes: {
                day_frequency:    1,
                stop_after_hours: 10
            }
        )

        site.scans.create(
            profile:             p,
            site_role:           site.roles[i % site.roles.size],
            user_agent:          user_agent,
            name:                "my scheduled scan #{scan_id}",
            schedule_attributes: {
                start_at:         Time.now + 3600,
                day_frequency:    1,
                month_frequency:  2,
                stop_after_hours: 10
            }
        )

        s = site.scans.create(
            profile:             p,
            site_role:           site.roles[i % site.roles.size],
            user_agent:          user_agent,
            name:                "my scheduled scan #{scan_id}",
            schedule_attributes: {
                day_frequency:    1,
                month_frequency:  2,
                stop_after_hours: 10
            }
        )
        s.save

        s.revisions.create(
            state:      'started',
            started_at: Time.now - 8000,
            stopped_at: Time.now - 4000
        )

        puts "[#{i}] Creating scan"
        scan = site.scans.create(
            profile:     p,
            site_role:   site.roles[i % site.roles.size],
            user_agent:  user_agent,
            name:        "my scan #{scan_id}",
            description: 'my description'
        )
        ap scan.errors.messages
        scan.schedule.destroy
        scan.save

        last_revision = nil
        revisions_per_scan.times do |j|
            break if issues.empty?

            puts "[#{i} - #{j}] Creating revision"
            revision = scan.revisions.create(
                state:      'started',
                started_at: Time.now - 8000,
                stopped_at: Time.now - 4000
            )

            scan.revisions.create(
                state:      'started',
                started_at: Time.now - 8000,
                stopped_at: Time.now - 4000
            )

            sitemap ||= report.sitemap.each do |url, code|
                revision.sitemap_entries.create(
                    url:  url,
                    code: code
                )
            end

            puts "[#{i} - #{j}] Creating issues"
            issues.pop.each do |issue|
                issue.variations.each do |variation|
                    ap issue.unique_id
                    ap issue.variations.first.page.dom.url

                    solo = variation.to_solo( issue )

                    next if !solo.check

                    if previous_scan = site.scans.all.find { |s| s != scan }
                        ap previous_scan.id
                        ap scan.id

                        prev_scan_revision = previous_scan.revisions.create(
                            state:      'started',
                            started_at: Time.now - 8000,
                            stopped_at: Time.now - 4000
                        )

                        prev_scan_revision.issues.create_from_arachni(
                            solo,
                            state: Issue::STATES.sample
                        )
                    end

                    is = revision.issues.create_from_arachni(
                        solo,
                        state: Issue::STATES.sample
                    )
                    ap is.errors.messages

                    break
                end

                # ap sitemap_entry.reload.issues.size
            end

            if last_revision
                last_revision.issues.each do |iss|
                    next if iss.state != 'fixed'

                    iss.fixed_by_revision = revision
                    iss.save
                    ap iss.errors.messages
                end
            end

            last_revision = revision
        end

        scan.revisions.create(
            state:      'started',
            started_at: Time.now - 8000
        )
    end
end
