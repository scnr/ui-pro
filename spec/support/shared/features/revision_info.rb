shared_examples_for 'Revision info' do |options = {}|
    let(:revision_info) { super() }
    let(:revision) { super() }

    def revision_info_refresh
        visit current_url
    end

    if options[:hide_revision_name]
        feature 'when not showing revision name' do
            scenario 'does not show revision name' do
                expect(revision_info).to_not have_content revision.to_s
            end

            scenario 'does not link to the revision' do
                expect(revision_info).to_not have_xpath "a[@href='#{site_scan_revision_path( revision.scan.site, revision.scan, revision )}']"
            end
        end
    else
        feature 'when showing revision name' do
            scenario 'shows revision name' do
                expect(revision_info).to have_content revision.to_s
            end

            scenario 'links to the revision' do
                expect(revision_info).to have_xpath "a[@href='#{site_scan_revision_path( revision.scan.site, revision.scan, revision )}']"
            end

            if options[:hide_scan_name]
                feature 'when not showing scan name' do
                    scenario 'does not show scan name' do
                        expect(revision_info).to_not have_content revision.scan.name
                    end
                end
            else
                feature 'when showing scan name' do
                    scenario 'shows scan name' do
                        expect(revision_info).to have_content "#{revision.scan} scan"
                    end
                end
            end
        end
    end

    feature 'when the revision has stopped' do
        before do
            revision.aborted!
            revision_info_refresh
        end

        scenario 'shows stop datetime' do
            expect(revision_info).to have_content I18n.l( revision.stopped_at )
        end

        scenario 'shows status' do
            expect(revision_info.text).to match /#{revision.status} on/i
        end

        if options[:extended]
            feature 'when showing extended data' do
                scenario 'shows start datetime' do
                    expect(revision_info).to have_content I18n.l( revision.started_at )
                end

                scenario 'shows scan duration' do
                    expect(revision_info).to have_content SCNR::Engine::Utilities.seconds_to_hms( revision.duration )
                end

                feature 'when timed out' do
                    before do
                        revision.timed_out = true
                        revision.save

                        revision_info_refresh
                    end

                    scenario 'reflects that' do
                        expect(revision_info).to have_content '(due to time out)'
                    end
                end
            end
        end
    end

    feature 'when the revision is in progress' do
        before do
            revision.stopped_at = nil
            revision.save

            revision_info_refresh
        end

        scenario 'shows start datetime' do
            expect(revision_info).to have_content I18n.l( revision.started_at )
        end

        scenario 'shows progress animation' do
            expect(revision_info).to have_css 'i.fa.fa-circle-o-notch'
        end

        if options[:extended]
            feature 'when showing extended data' do
                scenario 'shows scan duration' do
                    expect(revision_info).to have_content SCNR::Engine::Utilities.seconds_to_hms( revision.duration )
                end

                feature 'and has a Schedule#stop_after_hours' do
                    before do
                        revision.scan.schedule.stop_after_hours = 1
                        revision.scan.schedule.save

                        revision_info_refresh
                    end

                    scenario 'reflects that' do
                        expect(revision_info).to have_content 'will stop after'
                    end

                    scenario 'shows the value of the option' do
                        expect(revision_info).to have_content SCNR::Engine::Utilities.seconds_to_hms( revision.scan.schedule.stop_after_hours.hours.to_i )
                    end

                    scenario 'shows remaining time' do
                        expect(revision_info).to have_content SCNR::Engine::Utilities.seconds_to_hms( revision.scan.schedule.stop_after_hours.hours.to_i - revision.duration )
                    end

                    feature 'when Schedule#stop_suspend' do
                        before do
                            revision.scan.schedule.stop_suspend = true
                            revision.scan.schedule.save

                            revision_info_refresh
                        end

                        scenario 'reflects that' do
                            expect(revision_info).to have_content 'will suspend after'
                        end
                    end
                end
            end
        end
    end
end
