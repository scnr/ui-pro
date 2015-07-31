shared_examples_for 'Scan sidebar' do |options = {}|
    it_behaves_like 'Site sidebar', without_buttons: options[:without_site_buttons]

    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }

    let(:profile) { FactoryGirl.create :profile }

    let(:sidebar) { find '#sidebar #sidebar-scan' }
    let(:status) { sidebar.find '.scan-status' }

    def scan_sidebar_refresh
        visit current_url
    end

    scenario 'shows scan name' do
        expect(sidebar).to have_content scan.name
    end

    scenario 'shows scan link' do
        expect(sidebar).to have_xpath "//a[@href='#{site_scan_path( site, scan )}']"
    end

    feature 'when the scan has no status' do
        before do
            scan.status = nil
            scan.save
        end

        feature 'and is scheduled' do
            before do
                scan.schedule.start_at = Time.now + 1000
                scan.save

                scan_sidebar_refresh
            end

            scenario 'it shows it as pending' do
                expect(status).to have_content 'Pending'
                expect(status[:class]).to include 'label-default'
            end
        end

        feature 'and is unscheduled' do
            before do
                scan.schedule.start_at = nil
                scan.save

                scan_sidebar_refresh
            end

            scenario 'it shows it as unscheduled' do
                expect(status).to have_content 'Unscheduled'
                expect(status[:class]).to include 'label-default'
            end
        end
    end

    feature 'when the scan is' do
        before do
            scan
            scan_sidebar_refresh
        end

        feature 'active' do
            let(:scan) do
                super().tap { |s| s.revisions.create( started_at: Time.now ); s.scanning! }
            end

            scenario 'user sees pause button' do
                expect(sidebar).to have_xpath "//a[@href='#{pause_site_scan_path( site, scan )}' and @data-method='patch']"
            end

            scenario 'user sees suspend button' do
                expect(sidebar).to have_xpath "//a[@href='#{suspend_site_scan_path( site, scan )}' and @data-method='patch']"
            end

            scenario 'user sees abort button' do
                expect(sidebar).to have_xpath "//a[@href='#{abort_site_scan_path( site, scan )}' and @data-method='patch']"
            end

            scenario 'user sees edit button' do
                expect(sidebar).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
            end

            feature 'and scanning' do
                scenario 'user sees scan status' do
                    expect(status).to have_content 'Scanning'
                    expect(status[:class]).to include 'label-primary'
                end
            end

            feature 'and paused' do
                before do
                    scan.paused!
                    scan_sidebar_refresh
                end

                scenario 'user sees scan status' do
                    expect(status).to have_content 'Paused'
                    expect(status[:class]).to include 'label-warning'
                end

                scenario 'user does not see pause button' do
                    expect(sidebar).to_not have_xpath "//a[@href='#{pause_site_scan_path( site, scan )}']"
                end

                scenario 'user does not sees suspend button' do
                    expect(sidebar).to_not have_xpath "//a[@href='#{suspend_site_scan_path( site, scan )}']"
                end

                scenario 'user sees resume button' do
                    expect(sidebar).to have_xpath "//a[@href='#{resume_site_scan_path( site, scan )}' and @data-method='patch']"
                end
            end
        end

        feature 'suspended' do
            let(:scan) do
                super().tap { |s| s.revisions.create( started_at: Time.now ); s.suspended! }
            end

            scenario 'user sees scan status' do
                expect(status).to have_content 'Suspended'
                expect(status[:class]).to include 'label-default'
            end

            scenario 'user sees restore button' do
                expect(sidebar).to have_xpath "//a[@href='#{restore_site_scan_path( site, scan )}' and @data-method='patch']"
            end

            scenario 'user sees delete button' do
                expect(sidebar).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and @data-method='delete']"
            end
        end

        feature 'finished' do
            let(:scan) do
                super().tap do |s|
                    s.revisions.create(
                        started_at: Time.now,
                        stopped_at: Time.now
                    )
                    s.completed!
                end
            end

            feature 'and completed' do
                before do
                    scan.completed!
                    scan_sidebar_refresh
                end

                scenario 'user sees scan status' do
                    expect(status).to have_content 'Completed'
                    expect(status[:class]).to include 'label-success'
                end
            end

            feature 'and aborted' do
                before do
                    scan.aborted!
                    scan_sidebar_refresh
                end

                scenario 'user sees scan status' do
                    expect(status).to have_content 'Aborted'
                    expect(status[:class]).to include 'label-warning'
                end
            end

            feature 'and failed' do
                before do
                    scan.failed!
                    scan_sidebar_refresh
                end

                scenario 'user sees scan status' do
                    expect(status).to have_content 'Failed'
                    expect(status[:class]).to include 'label-danger'
                end
            end

            scenario 'user sees repeat button' do
                expect(sidebar).to have_xpath "//a[@href='#{repeat_site_scan_path( site, scan )}' and @data-method='post']"
            end

            scenario 'user sees edit button' do
                expect(sidebar).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
            end

            scenario 'user sees delete button' do
                expect(sidebar).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and @data-method='delete']"
            end
        end
    end
end
