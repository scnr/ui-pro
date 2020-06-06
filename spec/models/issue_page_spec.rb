require 'spec_helper'

describe IssuePage do
    subject { FactoryGirl.create :issue_page }

    expect_it { to have_one(:request).dependent(:destroy) }
    expect_it { to have_one(:response).dependent(:destroy) }
    expect_it { to have_one(:dom).dependent(:destroy) }
    expect_it { to belong_to(:sitemap_entry).counter_cache(true) }

    describe '.create_from_engine' do
        let(:engine_page) do
            Factory[:page]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Page}" do
            page = described_class.create_from_engine( engine_page )

            expect(page.request).to be_kind_of HttpRequest
            expect(page.request).to be_valid

            expect(page.response).to be_kind_of HttpResponse
            expect(page.response).to be_valid

            expect(page.dom).to be_kind_of IssuePageDom
        end
    end

end
