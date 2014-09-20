# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << admin.email

user = User.create(
    email:                 'test@stuff.com',
    password:              'testtest',
    password_confirmation: 'testtest'
)

arachni_defaults = {}
profile_columns  = Profile.column_names

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
# p.make_default
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

plan = Plan.create!(
    name:        'My plan',
    description: 'Plan description.',
    price:       20,
    profile_override_attributes: {
        scope_page_limit: 1_000
    }
)

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

site = user.sites.create(
    protocol: 'http',
    host:     'test.com',
    port:     8080
)
site.verification.verified!

scan = site.scans.create(
    profile:     p,
    name:        'my scan',
    description: 'my description',
    plan:        plan
)

scan.build_schedule
scan.save

revision = scan.revisions.create(
    state:      'started',
    started_at: Time.now
)

puts 'Creating issue'
ap native_issue = Arachni::Issue.from_rpc_data( MessagePack.load( IO.read( '/tmp/issue' ) ) )

native_request = native_issue.request
request = HttpRequest.create(
    url:         native_request.url,
    http_method: native_request.method,
    body:        native_request.effective_body,
    parameters:  native_request.parameters,
    headers:     native_request.headers,
    raw:         native_request.to_s
)

native_response = native_issue.response
response = HttpResponse.create(
    url:            native_response.url,
    code:           native_response.code,
    ip_address:     native_response.ip_address,
    body:           native_response.body,
    time:           native_response.time,
    headers:        native_response.headers,
    return_code:    native_response.return_code,
    return_message: native_response.return_message,
    raw_headers:    native_response.headers_string
)

data_flow_sinks = []
native_issue.page.dom.data_flow_sinks.each do |sink|
    data_flow_sinks << IssuePageDomDataFlowSink.create(
        object:                 sink.object,
        taint_value:            sink.taint,
        tainted_value:          sink.tainted_value,
        tainted_argument_index: sink.tainted_argument_index,
        function:               IssuePageDomFunction.create(
            name:      sink.function.name,
            source:    sink.function.source,
            arguments: sink.function.arguments
        ),
        stackframes:            sink.trace.map do |frame|
            IssuePageDomStackFrame.create(
                url:      frame.url,
                line:     frame.line,
                function: IssuePageDomFunction.create(
                    name:      frame.function.name,
                    source:    frame.function.source,
                    arguments: frame.function.arguments
                )
            )
        end
    )
end

execution_flow_sinks = []
native_issue.page.dom.execution_flow_sinks.each do |sink|
    execution_flow_sinks << IssuePageDomExecutionFlowSink.create(
        stackframes: sink.trace.map do |frame|
            IssuePageDomStackFrame.create(
                url:      frame.url,
                line:     frame.line,
                function: IssuePageDomFunction.create(
                    name:      frame.function.name,
                    source:    frame.function.source,
                    arguments: frame.function.arguments
                )
            )
        end
    )
end

transitions = []
native_issue.page.dom.transitions.each do |transition|
    transitions << IssuePageDomTransition.create(
        element: transition.element.to_s,
        event:   transition.event,
        time:    transition.time
    )
end

page_dom = IssuePageDom.create(
    url:                  native_issue.page.dom.url,
    body:                 native_issue.page.body,
    transitions:          transitions,
    data_flow_sinks:      data_flow_sinks,
    execution_flow_sinks: execution_flow_sinks
)

page = IssuePage.create(
    dom:      page_dom,
    request:  request,
    response: response
)

vector = Vector.create(
    action:              native_issue.vector.action,
    http_method:         native_issue.vector.http_method,
    seed:                native_issue.vector.seed,
    inputs:              native_issue.vector.inputs,
    affected_input_name: native_issue.vector.affected_input_name,
    html:                native_issue.vector.html,
    arachni_class:       native_issue.vector.class.to_s,
    kind:                native_issue.vector.type,
    original_inputs:     native_issue.vector.default_inputs
)

IssueType.find_by_check_shortname( 'xss_dom' ).issues.create(
    digest:    native_issue.digest.to_s,
    signature: native_issue.signature,
    proof:     native_issue.proof,
    trusted:   native_issue.trusted,
    active:    native_issue.active?,
    page:      page,
    vector:    vector,
    revision:  revision
)
