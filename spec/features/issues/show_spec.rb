include Warden::Test::Helpers
Warden.test_mode!

feature 'Issue page' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:issue) do
        Issue.create_from_arachni( Factory[:issue],
                                   revision: revision,
                                   type: FactoryGirl.create(:issue_type)
        )
    end
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: FactoryGirl.create(:profile) }
    let(:site) { FactoryGirl.create :site }
    let(:vector) { issue.vector }

    after(:each) do
        Warden.test_reset!
    end

    before do
        login_as user, scope: :user
        visit site_scan_revision_issue_path( site, scan, revision, issue )
    end

    scenario 'has title' do
        expect(page).to have_title issue.to_s
        expect(page).to have_title "Revision ##{revision.index}"
        expect(page).to have_title scan.name
        expect(page).to have_title site.url
        expect(page).to have_title 'Sites'
    end

    scenario 'has breadcrumbs' do
        breadcrumbs = find('ul.bread')

        expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

        expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Sites'
        expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq sites_path

        expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content site.url
        expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq site_path( site )

        expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content scan.name
        expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq site_scan_path( site, scan )

        expect(breadcrumbs.find('li:nth-of-type(5)')).to have_content "Revision ##{revision.index}"
        expect(breadcrumbs.find('li:nth-of-type(5) a').native['href']).to eq site_scan_revision_path( site, scan, revision )

        expect(breadcrumbs.find('li:nth-of-type(6)')).to have_content issue.to_s
        expect(breadcrumbs.find('li:nth-of-type(6) a').native['href']).to eq site_scan_revision_issue_path( site, scan, revision, issue )
    end

    feature 'page header' do
        let(:header) { find '.page-header' }

        feature 'heading' do
            let(:heading) { header.find 'h1' }

            feature 'contains' do
                scenario 'issue type name' do
                    expect(heading).to have_content issue.type.name
                end

                scenario 'vector type' do
                    expect(heading).to have_content issue.vector.kind
                end

                scenario 'affected input name' do
                    expect(heading).to have_content issue.vector.affected_input_name
                end

                scenario 'vector action link' do
                    expect(heading).to have_xpath "//a[@href='#{issue.vector.action}']"
                end

                scenario 'preferring page link' do
                    expect(heading).to have_xpath "//a[@href='#{issue.referring_page.dom.url}']"
                end
            end
        end

        scenario 'has severity label' do
            expect(header.find("p.label-severity-#{issue.type.severity}")).to have_content "#{issue.type.severity.capitalize} severity"
        end
    end

    feature 'info' do
        let(:info) { find '#info' }

        scenario 'has rendered Markdown description' do
            issue.type.description = '**Stuff**'
            issue.type.save

            visit site_scan_revision_issue_path( site, scan, revision, issue )

            expect(info.find('.description strong')).to have_content 'Stuff'
        end

        feature 'when there is a CWE' do
            scenario 'shows it as a reference' do
                issue.type.cwe = 1
                issue.type.references = []
                issue.type.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )

                references = info.find('.references')

                expect(references).to have_content 'CWE'
                expect(references).to have_xpath "//a[@href='#{issue.type.cwe_url}']"
            end
        end

        feature 'when there are references' do
            scenario 'shows them' do
                references = info.find('.references')

                expect(issue.type.references.size).to be >= 1

                issue.type.references.each do |reference|
                    expect(references).to have_xpath "//a[@href='#{reference.url}']"
                    expect(references).to have_content reference.title
                end
            end
        end

        feature 'when there are no references' do
            scenario 'shows nothing' do
                issue.type.cwe = nil
                issue.type.references = []
                issue.type.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )

                expect(info).to_not have_css '.references'
            end
        end
    end

    feature 'input vector' do
        let(:input_vector) { find '#input_vector' }

        feature 'when the input vector has no source' do
            before do
                vector.source = nil
                vector.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )
            end

            scenario 'it does not show it' do
                expect(input_vector).to_not have_css '.source'
            end
        end

        feature 'when the input vector has source' do
            let(:source) { input_vector.find('.source') }

            before do
                vector.source = '<form></form>'
                vector.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )
            end

            scenario 'it highlights it' do
                expect(source).to have_css '.CodeRay'
                expect(source).to have_content vector.source
            end
        end

        feature 'info' do
            let(:info) { input_vector.find '.input_vector-info' }

            scenario 'has vector type' do
                expect(info).to have_content vector.kind
            end

            feature 'when the issue is active' do
                before do
                    issue.active = true
                    issue.save

                    visit site_scan_revision_issue_path( site, scan, revision, issue )
                end

                scenario 'has HTTP method' do
                    expect(info).to have_content vector.http_method
                end
            end

            feature 'when the issue is not active' do
                before do
                    issue.active = false
                    issue.save

                    visit site_scan_revision_issue_path( site, scan, revision, issue )
                end

                scenario 'has HTTP method' do
                    expect(info).to_not have_content vector.http_method
                end
            end

            scenario 'has referring page URL' do
                expect(info).to have_xpath "//a[@href='#{issue.referring_page.dom.url}']"
            end

            scenario 'has vector action' do
                expect(info).to have_xpath "//a[@href='#{vector.action}']"
            end
        end

        feature 'when it has inputs' do
            before do
                vector.default_inputs = {
                    'myname'  => 'my value',
                    'myname1' => 'my value2'
                }
                vector.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )
            end

            let(:values) { input_vector.find '.input_vector-values .table-hash' }

            scenario 'it shows values' do
                vector.default_inputs.each do |k, v|
                    expect(values).to have_content k
                    expect(values).to have_content v
                end
            end

            feature 'when the issue has an affected input name' do
                before do
                    vector.affected_input_name = 'myname'
                    vector.save

                    visit site_scan_revision_issue_path( site, scan, revision, issue )
                end

                scenario 'it highlights the input' do
                    row = values.find('tr:nth-of-type(1)')

                    expect(row.find('th:nth-of-type(1)')).to have_content 'myname'
                    expect(row.find('th:nth-of-type(2)')).to have_content '='
                    expect(row.find('th:nth-of-type(3)')).to have_content 'my value'

                    expect(values.find('tr:nth-of-type(2)')).to_not have_xpath 'th'
                end
            end
        end

        feature 'when it has no inputs' do
            before do
                vector.default_inputs = {}
                vector.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )
            end

            scenario 'it does not show values' do
                expect(input_vector).to_not have_css '.input_vector-values'
            end
        end
    end

    feature 'reproduction' do
        let(:reproduction) { find '#reproduction' }

        feature 'when the issue is active' do
            before do
                issue.active = true
                issue.save
            end

            feature 'and has inputs' do
                before do
                    vector.inputs = {
                        'myname'  => 'my value',
                        'myname1' => 'my value2'
                    }
                    vector.save

                    visit site_scan_revision_issue_path( site, scan, revision, issue )
                end

                let(:values){ reproduction.find( '#reproduction-inputs .table-hash' ) }

                scenario 'it shows values' do
                    vector.inputs.each do |k, v|
                        expect(values).to have_content k
                        expect(values).to have_content v
                    end
                end

                feature 'when the issue has an affected input name' do
                    before do
                        vector.affected_input_name = 'myname'
                        vector.save

                        visit site_scan_revision_issue_path( site, scan, revision, issue )
                    end

                    scenario 'it highlights the input' do
                        row = values.find('tr:nth-of-type(1)')

                        expect(row.find('th:nth-of-type(1)')).to have_content 'myname'
                        expect(row.find('th:nth-of-type(2)')).to have_content '='
                        expect(row.find('th:nth-of-type(3)')).to have_content 'my value'

                        expect(values.find('tr:nth-of-type(2)')).to_not have_xpath 'th'
                    end
                end
            end

            feature 'and has no inputs' do
                before do
                    vector.inputs = {}
                    vector.save

                    visit site_scan_revision_issue_path( site, scan, revision, issue )
                end

                scenario 'it shows no inputs' do
                    expect(reproduction).to_not have_css '#reproduction-inputs'
                end
            end
        end

        feature 'when the issue is not active' do
            before do
                issue.active = false
                issue.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )
            end

            scenario 'it shows no inputs' do
                expect(reproduction).to_not have_css '#reproduction-inputs'
            end
        end

        feature 'when the issue has transitions' do
            let(:dom_transitions) { issue.page.dom.transitions }
            let(:transitions) { find '#reproduction-transitions' }

            scenario 'it lists them' do
                expect(dom_transitions.size).to be >= 1

                cnt = 1
                dom_transitions.each.with_index do |t, i|
                    next if t.event == :request

                    row = transitions.find( ".table-transitions > tbody > tr:nth-of-type(#{cnt})" )

                    expect(row).to have_content t.event
                    expect(row).to have_content t.element
                    expect(row).to_not have_content t.time

                    cnt += 1
                end
            end

            scenario 'it ignores request ones' do
                expect(dom_transitions.find { |t| t.event == :request }).to be_truthy
                expect(transitions).to_not have_content 'request'
            end

            feature 'when a transition has option' do
                scenario ':url' do
                    transition = dom_transitions[0]
                    row        = transitions.find( '.table-transitions > tbody > tr:nth-of-type(1)' )
                    options    = row.find( 'table.table-transition-options > tr:nth-of-type(1)' )

                    expect(options.find('th')).to have_content 'URL'
                    expect(options.find('td')).to have_content transition.options[:url]
                end

                scenario ':cookies' do
                    transition = dom_transitions[0]
                    row        = transitions.find( '.table-transitions > tbody > tr:nth-of-type(1)' )
                    options    = row.find( 'table.table-transition-options' )

                    expect(options.find('tr:nth-of-type(2) th')).to have_content 'Cookies'

                    cookies_table = options.find('tr:nth-of-type(3) td table')

                    transition.options[:cookies].each do |k, v|
                        expect(cookies_table).to have_content k
                        expect(cookies_table).to have_content v
                    end
                end

                scenario ':input' do
                    transition = dom_transitions[2]
                    row        = transitions.find( '.table-transitions > tbody > tr:nth-of-type(2)' )
                    options    = row.find( 'table.table-transition-options > tr:nth-of-type(1)' )

                    expect(options.find('th')).to have_content 'Value'
                    expect(options.find('td')).to have_content transition.options[:value]
                end

                scenario ':inputs' do
                    transition = dom_transitions[3]
                    row        = transitions.find( '.table-transitions > tbody > tr:nth-of-type(3)' )
                    options    = row.find( 'table.table-transition-options' )

                    expect(options.find('tr:nth-of-type(1) th')).to have_content 'Inputs'

                    inputs_table = options.find('tr:nth-of-type(2) td table')

                    transition.options[:inputs].each do |k, v|
                        expect(inputs_table).to have_content k
                        expect(inputs_table).to have_content v
                    end
                end
            end

            scenario 'it does not show HTTP request' do
                expect(reproduction).to_not have_css '#reproduction-request'
            end
        end

        feature 'when the issue has no transition' do
            before do
                issue.page.dom.transitions = []
                issue.page.dom.save

                issue.page.request.raw = 'stuff goes here'
                issue.page.request.save

                issue.vector.seed = nil
                issue.vector.save

                visit site_scan_revision_issue_path( site, scan, revision, issue )
            end

            let(:request) { reproduction.find '#reproduction-request' }

            scenario 'it does not show transitions' do
                expect(reproduction).to_not have_css '#reproduction-transitions'
            end

            scenario 'it shows HTTP request' do
                expect(request).to have_content issue.page.request.to_s
            end

            feature 'when the request includes the seed' do
                before do
                    issue.vector.seed = 'goes'
                    issue.vector.save

                    visit site_scan_revision_issue_path( site, scan, revision, issue )
                end

                scenario 'it highlights it' do
                    expect(request.find('.highlight')).to have_content issue.vector.seed
                end
            end
        end
    end

end
