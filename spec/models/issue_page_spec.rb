require 'spec_helper'

describe IssuePage do
    subject { FactoryGirl.create :issue_page }

    expect_it { to have_one(:request).dependent(:destroy) }
    expect_it { to have_one(:response).dependent(:destroy) }
    expect_it { to have_one(:dom).dependent(:destroy) }

    describe '.create_from_arachni' do
        let(:arachni_page) do
            Factory[:page]
        end

        it "creates a #{described_class} from #{Arachni::Page}" do
            page = described_class.create_from_arachni( arachni_page ).reload
            expect(page).to be_valid

            expect(page.request).to be_kind_of HttpRequest
            expect(page.request).to be_valid

            expect(page.response).to be_kind_of HttpResponse
            expect(page.response).to be_valid

            expect(page.dom).to be_kind_of IssuePageDom
            expect(page.dom).to be_valid
        end
    end

end
