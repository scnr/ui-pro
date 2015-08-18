require 'rails_helper'

describe PerformanceSnapshot, type: :model do
    subject { FactoryGirl.create :performance_snapshot }

    let(:statistics) do
        {
            seed:          '8f0510034adf8e1905ed47b7e141dbf3',
            http:          {
                request_count:               120209,
                response_count:              120209,
                time_out_count:              162,
                total_responses_per_second:  41.08373646212503,
                burst_response_time_sum:     3.963999,
                burst_response_count:        18,
                burst_responses_per_second:  20.98328921971754,
                burst_average_response_time: 0.22022216666666666,
                total_average_response_time: 0.3961567054297138,
                max_concurrency:             10,
                original_max_concurrency:    20
            },
            runtime:       3356.181309559,
            found_pages:   84,
            audited_pages: 569,
            current_page:  'http://stuff.com/path/here/'
        }
    end

    def step_through( min, max, step, &block )
        value = min

        while value <= max
            block.call value
            value += step
        end
    end

    describe '#http_time_out_count_state' do
        before do
            subject.http_request_count = http_request_count
        end
        let(:http_request_count) { 10_000 }
        let(:step) { 0.0001 }

        context 'when #http_time_out_count is between' do
            context '0%-1.25% of total requests' do
                it 'returns excellent' do
                    step_through( 0.0, 0.0125, step ) do |value|
                        subject.http_time_out_count = http_request_count * value
                        expect(subject.http_time_out_count_state).to eq :excellent
                    end
                end
            end

            context '1.25%-2.5% of total requests' do
                it 'returns good' do
                    step_through( 0.0125, 0.025, step ) do |value|
                        subject.http_time_out_count = http_request_count * value
                        expect(subject.http_time_out_count_state).to eq :good
                    end
                end
            end

            context '2.5%-3.75% of total requests' do
                it 'returns fair' do
                    step_through( 0.025, 0.0375, step ) do |value|
                        subject.http_time_out_count = http_request_count * value
                        expect(subject.http_time_out_count_state).to eq :fair
                    end
                end
            end

            context '>= 3.75% of total requests' do
                it 'returns poor' do
                    step_through( 0.0375, 0.1, step ) do |value|
                        subject.http_time_out_count = http_request_count * value
                        expect(subject.http_time_out_count_state).to eq :poor
                    end
                end
            end
        end
    end

    describe '#max_http_time_out_count' do
        before do
            subject.http_request_count = http_request_count
        end
        let(:http_request_count) { 10_000 }

        it 'returns 5% of total requests' do
            expect(subject.max_http_time_out_count).to eq 500
        end
    end

    describe '#http_time_out_count_pct' do
        before do
            subject.http_request_count  = http_request_count
            subject.http_time_out_count = 1_000
        end
        let(:http_request_count) { 10_000 }

        it 'returns the percentage of timed out requests based on total requests' do
            expect(subject.http_time_out_count_pct).to eq 10
        end
    end

    describe '#http_average_responses_per_second_state' do
        context 'when #http_average_responses_per_second is between' do
            context '0-29' do
                it 'returns poor' do
                    (0..29).each do |value|
                        subject.http_average_responses_per_second = value
                        expect(subject.http_average_responses_per_second_state).to eq :poor
                    end
                end
            end

            context '30-59' do
                it 'returns fair' do
                    (30..59).each do |value|
                        subject.http_average_responses_per_second = value
                        expect(subject.http_average_responses_per_second_state).to eq :fair
                    end
                end
            end

            context '60-89' do
                it 'returns good' do
                    (60..89).each do |value|
                        subject.http_average_responses_per_second = value
                        expect(subject.http_average_responses_per_second_state).to eq :good
                    end
                end
            end

            context '>= 90' do
                it 'returns excellent' do
                    (90..1000).each do |value|
                        subject.http_average_responses_per_second = value
                        expect(subject.http_average_responses_per_second_state).to eq :excellent
                    end
                end
            end
        end
    end

    describe '#http_max_concurrency_state' do
        before do
            subject.http_original_max_concurrency = 20
        end

        context 'when #http_max_concurrency is between' do
            context '0%-24% of #http_original_max_concurrency' do
                it 'returns poor' do
                    (0..4).each do |value|
                        subject.http_max_concurrency = value
                        expect(subject.http_max_concurrency_state).to eq :poor
                    end
                end
            end

            context '25%-49% of #http_original_max_concurrency' do
                it 'returns fair' do
                    (5..9).each do |value|
                        subject.http_max_concurrency = value
                        expect(subject.http_max_concurrency_state).to eq :fair
                    end
                end
            end

            context '50%-74% of #http_original_max_concurrency' do
                it 'returns good' do
                    (10..14).each do |value|
                        subject.http_max_concurrency = value
                        expect(subject.http_max_concurrency_state).to eq :good
                    end
                end
            end

            context '>= 75% of #http_original_max_concurrency' do
                it 'returns excellent' do
                    (15..1000).each do |value|
                        subject.http_max_concurrency = value
                        expect(subject.http_max_concurrency_state).to eq :excellent
                    end
                end
            end
        end
    end

    describe '#http_average_response_time_state' do
        let(:step) { 0.01 }

        context 'when #http_average_response_time is between' do
            context '0.0-0.25' do
                it 'returns poor' do
                    step_through( 0.0, 0.25, step ) do |value|
                        subject.http_average_response_time = value
                        expect(subject.http_average_response_time_state).to eq :excellent
                    end
                end
            end

            context '0.25-0.5' do
                it 'returns poor' do
                    step_through( 0.25, 0.5, step ) do |value|
                        subject.http_average_response_time = value
                        expect(subject.http_average_response_time_state).to eq :good
                    end
                end
            end

            context '0.5-0.75' do
                it 'returns fair' do
                    step_through( 0.5, 0.75, step ) do |value|
                        subject.http_average_response_time = value
                        expect(subject.http_average_response_time_state).to eq :fair
                    end
                end
            end

            context '>= 0.75' do
                it 'returns poor' do
                    step_through( 0.75, 10.0, step ) do |value|
                        subject.http_average_response_time = value
                        expect(subject.http_average_response_time_state).to eq :poor
                    end
                end
            end
        end
    end

    describe '.determine_state' do
        pending
    end

    describe '.create_from_arachni' do
        it' creates a model from RPC progress statistics' do
            snapshot = described_class.create_from_arachni( statistics )

            expect(snapshot.http_request_count).to eq statistics[:http][:request_count]
            expect(snapshot.http_response_count).to eq statistics[:http][:response_count]
            expect(snapshot.http_time_out_count).to eq statistics[:http][:time_out_count]
            expect(snapshot.http_average_responses_per_second).to eq statistics[:http][:total_responses_per_second]
            expect(snapshot.http_average_response_time).to eq statistics[:http][:total_average_response_time]
            expect(snapshot.http_max_concurrency).to eq statistics[:http][:max_concurrency]

            expect(snapshot.runtime).to eq statistics[:runtime]
            expect(snapshot.page_count).to eq statistics[:found_pages]
            expect(snapshot.current_page).to eq statistics[:current_page]
        end
    end

    describe '.arachni_to_attributes' do
        it' converts RPC progress statistics to model attributes' do
            expect(described_class.arachni_to_attributes( statistics )).to eq(
                http_request_count:                statistics[:http][:request_count],
                http_response_count:               statistics[:http][:response_count],
                http_time_out_count:               statistics[:http][:time_out_count],
                http_average_responses_per_second: statistics[:http][:total_responses_per_second],
                http_average_response_time:        statistics[:http][:total_average_response_time],
                http_max_concurrency:              statistics[:http][:max_concurrency],
                http_original_max_concurrency:     statistics[:http][:original_max_concurrency],
                runtime:                           statistics[:runtime],
                page_count:                        statistics[:found_pages],
                current_page:                      statistics[:current_page]
            )
        end
    end
end
