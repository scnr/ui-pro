require 'spec_helper'

describe SiteProfile do
    subject { FactoryGirl.create :site_profile, site: site }
    let(:site) { FactoryGirl.create :site }

    expect_it { to belong_to :site }
    expect_it { to belong_to :revision }

end
