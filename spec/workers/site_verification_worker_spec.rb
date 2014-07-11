describe SiteVerificationWorker do
    before { Typhoeus.stub(verification.url).and_return(response) }

    subject { described_class.new }
    let(:site) { FactoryGirl.create :site }
    let(:verification) { site.verification }

    let(:response) do
        Typhoeus::Response.new(
            code:        200,
            body:        verification.code,
            return_code: :ok
        )
    end

    context "when the #{SiteVerification} has been" do
        context 'marked as done' do
            before { verification.verified! }

            it 'returns nil' do
                expect(subject.perform(verification.id)).to be_nil
            end
        end

        context 'deleted' do
            before { site.destroy }

            it 'returns nil' do
                expect(subject.perform(verification.id)).to be_nil
            end
        end
    end

    it 'sets the initial state to :started' do
        expect_any_instance_of(verification.class).to receive(:started!)
        subject.perform(verification.id)
    end

    context 'when the site' do
        before { subject.perform(verification.id) }

        context 'returns a 200 code' do
            context 'and the response body' do
                context "is identical to the #{SiteVerification}#code" do
                    it "sets the #{SiteVerification}#state to verified" do
                        expect(verification.reload).to be_verified
                    end
                end

                context "differs only in whitespace to #{SiteVerification}#code" do
                    let(:response) do
                        Typhoeus::Response.new(
                            code:        200,
                            body:        "  #{verification.code}    ",
                            return_code: :ok
                        )
                    end

                    it "sets the #{SiteVerification}#state to failed" do
                        expect(verification.reload).to be_verified
                    end
                end

                context "is different to #{SiteVerification}#code" do
                    let(:response) do
                        Typhoeus::Response.new(
                            code:        200,
                            body:        'stuff',
                            return_code: :ok
                        )
                    end

                    it "sets the #{SiteVerification}#state to failed" do
                        expect(verification.reload).to be_failed
                    end

                    it "sets the #{SiteVerification}#message" do
                        expect(verification.reload.message).to_not be_empty
                    end
                end
            end
        end

        context 'returns a non 200 code' do
            let(:response) do
                Typhoeus::Response.new(
                    code:        404,
                    body:        'stuff',
                    return_code: :ok
                )
            end

            it "sets the #{SiteVerification}#state to failed" do
                expect(verification.reload).to be_failed
            end

            it "sets the #{SiteVerification}#message" do
                expect(verification.reload.message).to_not be_empty
            end
        end

        context 'is unreachable' do
            let(:response) do
                Typhoeus::Response.new(
                    code:        0,
                    return_code: :timeout
                )
            end

            it "sets the #{SiteVerification}#state to failed" do
                expect(verification.reload).to be_failed
            end

            it "sets the #{SiteVerification}#message" do
                expect(verification.reload.message).to_not be_empty
            end
        end
    end

    context 'when an exception is raised' do
        before do
            allow_any_instance_of(verification.class).to receive(:started!) { raise_exception }
            subject.perform(verification.id)
        end

        let(:raise_exception) { raise 'Test' }
        let(:exception) do
            begin
                raise_exception
            rescue => e
                e
            end
        end
        let(:response) do
            Typhoeus::Response.new(
                code:        0,
                return_code: :timeout
            )
        end

        it "sets the #{SiteVerification}#state to error" do
            expect(verification.reload).to be_error
        end

        it "sets the #{SiteVerification}#message" do
            expect(verification.reload.message).to include exception.class.to_s
            expect(verification.reload.message).to include exception.to_s
        end
    end

end
