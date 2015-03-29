# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
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
    audit_cookies: true,
    input_values:  Arachni::Options.input.default_values
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
    checks:      %w(sqli sqli_blind_differential sqli_blind_timing)
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

scans_size         = 2
revisions_per_scan = 3

[
    # '/home/zapotek/workspace/arachni/spec/support/fixtures/report.afr',
    '/home/zapotek/Downloads/report.afr'
].each do |afr|
    sitemap    = nil
    report     = Arachni::Report.load( afr )
    parsed_url = Arachni::URI( report.url )
    issues     = report.issues.shuffle.chunk( scans_size * revisions_per_scan )

    puts 'Creating site'
    site = user.sites.create(
        protocol: parsed_url.scheme,
        host:     parsed_url.host,
        port:     parsed_url.port || 80
    )

    scans_size.times do |i|
        break if issues.empty?

        puts "[#{i}] Creating scan"
        scan = site.scans.create(
            profile:     p,
            name:        "my scan #{i}",
            description: 'my description'
        )

        scan.build_schedule
        scan.save

        revisions_per_scan.times do |j|
            break if issues.empty?

            puts "[#{i} - #{j}] Creating revision"
            revision = scan.revisions.create(
                state:      'started',
                started_at: Time.now - 8000,
                stopped_at: Time.now - 4000
            )

            sitemap ||= report.sitemap.each do |url, code|
                site.sitemap_entries.create(
                    url:      url,
                    code:     code,
                    revision: revision
                )
            end

            puts "[#{i} - #{j}] Creating issues"
            issues.pop.each do |issue|
                sitemap_entry = site.sitemap_entries.find_by_url( issue.variations.first.page.dom.url )
                sitemap_entry ||= site.sitemap_entries.create(
                    url:      issue.variations.first.page.dom.url,
                    code:     issue.variations.first.response.code,
                    revision: revision
                )

                issue.variations.each do |variation|
                    ap issue.unique_id
                    ap issue.variations.first.page.dom.url

                    solo = variation.to_solo( issue )
                    next if !solo.check

                    revision.issues.create_from_arachni( solo, sitemap_entry: sitemap_entry )
                end

                # ap sitemap_entry.reload.issues.size
            end
        end
    end
end
