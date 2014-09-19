require 'spec_helper'

describe HttpResponse do
    subject { FactoryGirl.create :http_response }

    describe '#headers' do
        it 'is a Hash' do
            expect( subject.headers ).to be_kind_of Hash
        end
    end

end
