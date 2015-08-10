describe ScanScheduler::Helpers::ErrorHandling do
    subject { ScanScheduler.instance }

    let(:exception) { Arachni::RPC::Exceptions::Base.new }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    before do
        subject.reset
    end

    describe '#handle_if_rpc_error' do
        let(:args) do
            [revision, exception]
        end

        context 'if the object is an RPC exception' do
            it 'passes the arguments to #handle_rpc_error' do
                expect(subject).to receive(:handle_rpc_error).with( *args )
                subject.handle_if_rpc_error *args
            end
        end

        context 'if the object is not an RPC exception' do
            let(:exception) do
                Object.new
            end

            it 'does not passes the arguments to #handle_rpc_error' do
                expect(subject).to_not receive(:handle_rpc_error)
                subject.handle_if_rpc_error *args
            end
        end
    end

    describe '#handle_rpc_error' do
        let(:args) do
            [revision, exception]
        end

        it 'passes the arguments to #log_exception_for' do
            expect(subject).to receive(:log_exception_for).with( *args )
            subject.handle_rpc_error( *args )
        end

        it 'passes the revision to #kill_instance_for' do
            expect(subject).to receive(:kill_instance_for).with( revision )
            subject.handle_rpc_error( *args )
        end

        it 'passes the revision to #finish' do
            expect(subject).to receive(:finish).with( revision )
            subject.handle_rpc_error( *args )
        end

        it 'sets the scan status to failed' do
            subject.handle_rpc_error( *args )
            expect(revision).to be_failed
        end
    end
end
