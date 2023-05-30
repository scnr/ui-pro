# frozen_string_literal: true

RSpec.describe Device do
    subject { FactoryGirl.create :device }

    expect_it { to have_many :scans }
    expect_it { to have_many :revisions }
    expect_it { to validate_uniqueness_of :name }
    expect_it { to validate_presence_of :name }
    expect_it { to validate_presence_of :device_user_agent }
    expect_it { to validate_presence_of :device_width }
    expect_it { to validate_numericality_of :device_width }
    expect_it { to validate_presence_of :device_height }
    expect_it { to validate_numericality_of :device_height }

    describe 'broadcast callbacks' do
        let(:queue_name) { 'default' }

        describe 'after_create_commit' do
            subject(:device) { build(:device) }

            it 'calls Broadcasts::Devices::CreateJob' do
                expect { device.save }.to have_enqueued_job(Broadcasts::Devices::CreateJob).with(device.id).on_queue(queue_name)
            end
        end

        describe 'after_update_commit' do
            subject(:device) { create(:device) }

            it 'calls Broadcasts::Devices::CreateJob' do
                expect { device.save }.to have_enqueued_job(Broadcasts::Devices::UpdateJob).with(device.id).on_queue(queue_name)
            end
        end

        describe 'after_destroy_commit' do
            subject(:device) { create(:device) }

            it 'calls Broadcasts::Devices::CreateJob' do
                expect { device.destroy }.to have_enqueued_job(Broadcasts::Devices::DestroyJob).with(device.id).on_queue(queue_name)
            end
        end
    end
end
