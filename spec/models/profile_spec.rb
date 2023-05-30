# frozen_string_literal: true

RSpec.describe Profile do
    subject { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    expect_it { to belong_to :user }
    expect_it { to have_many :scans }

    describe '#to_s' do
        it 'returns #name' do
            expect(subject.to_s).to eq subject.name
        end
    end

    describe 'broadcast callbacks' do
        let(:queue_name) { 'anycable' }

        describe 'after_create_commit' do
            subject(:profile) { build(:profile) }

            # Due to spec/factories/profiles.rb#L5 callbacks are not runs.
            xit 'enqueues Broadcasts::Profiles::CreateJob' do
                expect { profile.save }.to have_enqueued_job(Broadcasts::Profiles::CreateJob).with(profile.id).on_queue(queue_name)
            end
        end

        describe 'after_update_commit' do
            subject(:profile) { create(:profile) }

            it 'enqueues Broadcasts::Profiles::CreateJob' do
                expect { profile.touch }.to have_enqueued_job(Broadcasts::Profiles::UpdateJob).with(profile.id).on_queue(queue_name)
            end
        end

        describe 'after_destroy_commit' do
            subject(:profile) { create(:profile, user: user) }

            it 'enqueues Broadcasts::Profiles::CreateJob' do
                expect { profile.destroy }.to have_enqueued_job(Broadcasts::Profiles::DestroyJob).with(profile.id, user.id).on_queue(queue_name)
            end
        end
    end
end
