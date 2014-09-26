require 'spec_helper'

describe SitemapEntry do
    expect_it { to belong_to :site }
    expect_it { to belong_to :revision }

    expect_it { to have_many :issues }
end
