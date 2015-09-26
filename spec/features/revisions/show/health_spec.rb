feature 'Revision health' do
    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site, user: user }
    let(:profile) { FactoryGirl.create :profile }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan, performance_snapshot: performance_snapshot }
    let(:performance_snapshot) do
        FactoryGirl.create :performance_snapshot,
                           http_request_count: http_request_count,
                           http_original_max_concurrency: http_original_max_concurrency
    end

    let(:http_request_count) { 10_000 }
    let(:http_original_max_concurrency) { 20 }

    def refresh
        visit site_scan_revision_path( site, scan, revision )
        click_link 'Health'
    end

    before do
        revision

        user.sites << site

        login_as user, scope: :user
        refresh
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:scan_results) { find '#scan-results' }
    let(:health) { find '#health' }

    let(:state) { section.find 'h4.health-state' }
    let(:description) { section.find 'p.health-description' }

    feature 'Scanner performance' do
        let(:section) { health.find '#health-scanner_performance' }

        feature 'when Excellent' do
            before do
                performance_snapshot.http_max_concurrency = 20
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Excellent'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-excellent'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'configured maximum'
            end
        end

        feature 'when Good' do
            before do
                performance_snapshot.http_max_concurrency = 12
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Good'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-good'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'lowered a little'
            end
        end

        feature 'when Fair' do
            before do
                performance_snapshot.http_max_concurrency = 7
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Fair'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-fair'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'lowered considerably'
            end
        end

        feature 'when Poor' do
            before do
                performance_snapshot.http_max_concurrency = 3
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Poor'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-poor'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'greatly lowered'
            end
        end

        feature 'gauge', js: true  do
            before do
                performance_snapshot.http_original_max_concurrency = 15
                performance_snapshot.http_max_concurrency          = 10
                performance_snapshot.save

                refresh
            end

            let(:gauge) { health.find '#current_http_max_concurrency' }

            it 'shows current concurrency' do
                expect(gauge.find('.c3-gauge-value')).to have_content '10'
            end

            it 'shows unit' do
                expect(gauge.find('.c3-chart-arcs-gauge-unit')).to have_content 'concurrent requests'
            end

            it 'shows min' do
                expect(gauge.find('.c3-chart-arcs-gauge-min')).to have_content '1'
            end

            it 'shows max' do
                expect(gauge.find('.c3-chart-arcs-gauge-max')).to have_content '15'
            end
        end
    end

    feature 'Server performance' do
        let(:section) { health.find '#health-server_performance' }

        feature 'when Excellent' do
            before do
                performance_snapshot.http_average_responses_per_second = 100
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Excellent'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-excellent'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'very well'
            end
        end

        feature 'when Good' do
            before do
                performance_snapshot.http_average_responses_per_second = 70
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Good'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-good'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'well enough'
            end
        end

        feature 'when Fair' do
            before do
                performance_snapshot.http_average_responses_per_second = 40
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Fair'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-fair'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'somewhat slow'
            end
        end

        feature 'when Poor' do
            before do
                performance_snapshot.http_average_responses_per_second = 10
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Poor'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-poor'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'poorly'
            end
        end

        feature 'gauge', js: true  do
            before do
                performance_snapshot.http_average_responses_per_second = 43.87654
                performance_snapshot.save

                refresh
            end

            let(:gauge) { health.find '#current_http_average_responses_per_second' }

            it 'shows requests per second' do
                expect(gauge.find('.c3-gauge-value')).to have_content '43'
            end

            it 'shows unit' do
                expect(gauge.find('.c3-chart-arcs-gauge-unit')).to have_content 'responses/second'
            end

            it 'shows min' do
                expect(gauge.find('.c3-chart-arcs-gauge-min')).to have_content '0'
            end

            it 'shows max' do
                expect(gauge.find('.c3-chart-arcs-gauge-max')).to have_content '120'
            end
        end
    end

    feature 'Server responsiveness' do
        let(:section) { health.find '#health-server_responsiveness' }

        feature 'when Excellent' do
            before do
                performance_snapshot.http_average_response_time = 0.2
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Excellent'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-excellent'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'under any stress'
            end
        end

        feature 'when Good' do
            before do
                performance_snapshot.http_average_response_time = 0.4
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Good'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-good'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'little stress'
            end
        end

        feature 'when Fair' do
            before do
                performance_snapshot.http_average_response_time = 0.6
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Fair'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-fair'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'under stress'
            end
        end

        feature 'when Poor' do
            before do
                performance_snapshot.http_average_response_time = 0.8
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Poor'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-poor'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'under a lot of stress'
            end
        end

        feature 'gauge', js: true  do
            before do
                performance_snapshot.http_average_response_time = 0.8
                performance_snapshot.save

                refresh
            end

            let(:gauge) { health.find '#current_http_average_response_time' }

            it 'shows average response time' do
                expect(gauge.find('.c3-gauge-value')).to have_content '0.8'
            end

            it 'shows unit' do
                expect(gauge.find('.c3-chart-arcs-gauge-unit')).to have_content 'seconds/response'
            end

            it 'shows min' do
                expect(gauge.find('.c3-chart-arcs-gauge-min')).to have_content '0'
            end

            it 'shows max' do
                expect(gauge.find('.c3-chart-arcs-gauge-max')).to have_content '1'
            end
        end
    end

    feature 'Network reliability' do
        let(:section) { health.find '#health-network_reliability' }

        feature 'when Excellent' do
            before do
                performance_snapshot.http_time_out_count = http_request_count * 0.01
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Excellent'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-excellent'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'highly reliable'
            end
        end

        feature 'when Good' do
            before do
                performance_snapshot.http_time_out_count = http_request_count * 0.020
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Good'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-good'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'small amount'
            end
        end

        feature 'when Fair' do
            before do
                performance_snapshot.http_time_out_count = http_request_count * 0.03
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Fair'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-fair'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'considerable amount'
            end
        end

        feature 'when Poor' do
            before do
                performance_snapshot.http_time_out_count = http_request_count * 0.04
                performance_snapshot.save

                refresh
            end

            it 'shows it' do
                expect(state).to have_content 'Poor'
            end

            it 'uses the appropriate color' do
                expect(state[:class]).to have_content 'text-state-poor'
            end

            it 'uses the appropriate description' do
                expect(description).to have_content 'large amount'
            end
        end

        feature 'gauge', js: true  do
            before do
                performance_snapshot.http_time_out_count = http_request_count * 0.032345678
                performance_snapshot.save

                refresh
            end

            let(:gauge) { health.find '#current_http_time_out_count' }

            it 'shows percentage based on total requests' do
                expect(gauge.find('.c3-gauge-value')).to have_content '3.23%'
            end

            it 'shows unit' do
                expect(gauge.find('.c3-chart-arcs-gauge-unit')).to have_content 'timed out requests'
            end

            it 'shows min' do
                expect(gauge.find('.c3-chart-arcs-gauge-min')).to have_content '0'
            end

            it 'shows max' do
                expect(gauge.find('.c3-chart-arcs-gauge-max')).to have_content '5'
            end
        end
    end

    feature 'Request counter', js: true do
        let(:section) { health.find '#health-request_counter' }

        feature 'gauge', js: true  do
            let(:gauge) { health.find '#current_http_request_count' }

            it 'shows count' do
                expect(gauge.find('.c3-gauge-value')).to have_content '10,000'
            end

            it 'shows unit' do
                expect(gauge.find('.c3-chart-arcs-gauge-unit')).to have_content 'requests'
            end

            it 'does not show min' do
                expect(gauge).to_not have_css '.c3-chart-arcs-gauge-min'
            end

            it 'does not show max' do
                expect(gauge).to_not have_css '.c3-chart-arcs-gauge-max'
            end
        end
    end
end
