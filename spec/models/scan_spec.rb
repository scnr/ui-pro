require 'spec_helper'

describe Scan do
    subject { FactoryGirl.create :scan, site: site }
    let(:other_scan) { FactoryGirl.create :scan, site: site }

    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site }

    expect_it { to belong_to :site }

    describe :validations do
        describe '#name' do
            let(:name) { 'stuff' }

            it 'is required' do
                subject.name = ''
                expect(subject.save).to be_falsey

                expect(subject.errors).to include :name
            end

            context 'for each #site' do
                it 'is unique' do
                    subject.name = name
                    expect(subject.save).to be_truthy

                    other_scan.name = name
                    expect(other_scan.save).to be_falsey

                    expect(other_scan.errors).to include :name

                    # With different sites.

                    subject.name = name
                    expect(subject.save).to be_truthy

                    other_scan.site = other_site
                    other_scan.name = name
                    expect(other_scan.save).to be_truthy
                end
            end
        end
    end
end
