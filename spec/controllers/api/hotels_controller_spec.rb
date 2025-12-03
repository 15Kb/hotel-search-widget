require 'rails_helper'

RSpec.describe Api::HotelsController, type: :controller do
  let(:boom_service) { instance_double(BoomNowService) }

  before do
    allow(BoomNowService).to receive(:new).and_return(boom_service)
  end

  describe 'GET #cities' do
    let(:cities_response) do
      {
        cities: ['Hollywood', 'Miami', 'Fort Lauderdale']
      }
    end

    context 'when successful' do
      before do
        allow(boom_service).to receive(:fetch_cities).and_return(cities_response)
      end

      it 'returns list of cities' do
        get :cities, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:cities]).to eq(['Hollywood', 'Miami', 'Fort Lauderdale'])
      end
    end

    context 'when service returns error' do
      before do
        allow(boom_service).to receive(:fetch_cities).and_return({ error: 'API Error' })
      end

      it 'returns empty cities array' do
        get :cities, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:cities]).to eq([])
      end
    end

    context 'when service raises exception' do
      before do
        allow(boom_service).to receive(:fetch_cities).and_raise(StandardError, 'Connection failed')
      end

      it 'returns empty cities array' do
        get :cities, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:cities]).to eq([])
      end
    end
  end

  describe 'POST #search' do
    let(:listings_response) do
      {
        listings: [
          {
            id: 1,
            title: 'Luxury Beach House',
            city_name: 'Hollywood',
            beds: 3,
            baths: 2,
            accommodates: 6,
            pictures: [
              { large: 'https://example.com/image.jpg' }
            ],
            amenities: ['WiFi', 'Pool', 'Parking']
          }
        ],
        pagi_info: {
          count: 1,
          page: 1,
          per_page: 50
        }
      }
    end

    context 'with valid location' do
      before do
        allow(boom_service).to receive(:search_hotels).and_return(listings_response)
      end

      it 'returns formatted hotel results' do
        post :search, params: { location: 'Hollywood' }, format: :json
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:hotels]).to be_an(Array)
        expect(json_response[:hotels].first[:name]).to eq('Luxury Beach House')
        expect(json_response[:hotels].first[:location]).to eq('Hollywood')
      end

      it 'formats hotel images from pictures array' do
        post :search, params: { location: 'Hollywood' }, format: :json
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:hotels].first[:image]).to eq('https://example.com/image.jpg')
      end

      it 'includes pagination info' do
        post :search, params: { location: 'Hollywood' }, format: :json
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:total]).to eq(1)
        expect(json_response[:page]).to eq(1)
      end
    end

    context 'without location parameter' do
      it 'returns bad request error' do
        post :search, params: {}, format: :json
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:error]).to eq('Location is required')
      end
    end

    context 'when service returns error' do
      before do
        allow(boom_service).to receive(:search_hotels).and_return({ error: 'API Error' })
      end

      it 'returns unprocessable entity status' do
        post :search, params: { location: 'Hollywood' }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when service raises exception' do
      before do
        allow(boom_service).to receive(:search_hotels).and_raise(StandardError, 'Network error')
      end

      it 'returns internal server error' do
        post :search, params: { location: 'Hollywood' }, format: :json
        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:error]).to eq('Internal server error')
      end
    end
  end
end

