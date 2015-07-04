describe ScanScheduler::Helpers::Logging do
    subject { ScanScheduler.instance }

    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    pending
end
