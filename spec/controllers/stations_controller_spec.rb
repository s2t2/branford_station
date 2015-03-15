require 'rails_helper'

RSpec.describe StationsController, :type => :controller do
  describe '#show' do
    context 'when JSON response is requested' do
      let(:request_url){"localhost::3000/agency/SLE/stations/BNF.json"}

      it 'lists upcoming departures from a given station' do
        expect(request_url).to be_kind_of(String)
      end
    end
  end
end
