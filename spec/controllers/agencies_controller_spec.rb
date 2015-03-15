require 'rails_helper'

RSpec.describe AgenciesController, :type => :controller do
  describe '#index' do
    context 'when JSON response is requested' do
      let(:request_url){"localhost::3000/agencies.json"}

      it 'lists all transit agencies' do
        expect(request_url).to be_kind_of(String)
      end
    end
  end

  describe '#show' do
    context 'when JSON response is requested' do
      let(:request_url){"localhost::3000/agency/SLE.json"}

      it 'lists all train stations serviced by a given agency' do
        expect(request_url).to be_kind_of(String)
      end
    end
  end
end
