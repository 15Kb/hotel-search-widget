require 'rails_helper'

RSpec.describe 'Hotels API', type: :request do
  let(:base_url) { 'https://app.boomnow.com/open_api/v1' }
  let(:access_token) { 'test_token_abc123' }
  
  before do
    # Stub authentication
    stub_request(:post, "#{base_url}/auth/token")
      .to_return(
        status: 201,
        body: {
          token_type: 'Bearer',
          expires_in: 3600,
          access_token: access_token
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'GET /api/hotels/cities' do
    before do
      stub_request(:get, "#{base_url}/listings/cities")
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(
          status: 200,
          body: {
            cities: ['Hollywood', 'Miami Beach', 'Fort Lauderdale', 'Tampa']
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns list of available cities' do
      get '/api/hotels/cities'
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body, symbolize_names: true)
      
      expect(json_response[:cities]).to be_an(Array)
      expect(json_response[:cities]).to include('Hollywood', 'Miami Beach')
    end
  end

  describe 'POST /api/hotels/search' do
    let(:listings_response) do
      {
        listings: [
          {
            id: 101,
            title: 'Oceanfront Villa',
            city_name: 'Hollywood',
            beds: 4,
            baths: 3,
            accommodates: 8,
            pictures: [
              {
                large: 'https://example.com/villa-large.jpg',
                thumbnail: 'https://example.com/villa-thumb.jpg'
              }
            ],
            amenities: ['WiFi', 'Pool', 'Kitchen', 'AC'],
            marketing_content: {
              description: 'Beautiful oceanfront villa with stunning views'
            }
          },
          {
            id: 102,
            title: 'Cozy Downtown Apartment',
            city_name: 'Hollywood',
            beds: 2,
            baths: 1,
            accommodates: 4,
            pictures: [],
            amenities: ['WiFi', 'Parking']
          }
        ],
        pagi_info: {
          count: 2,
          page: 1,
          per_page: 50
        }
      }
    end

    before do
      stub_request(:get, %r{#{base_url}/listings\?.*})
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(
          status: 200,
          body: listings_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    context 'with valid location' do
      it 'returns search results' do
        post '/api/hotels/search', params: { location: 'Hollywood' }
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(json_response[:hotels]).to be_an(Array)
        expect(json_response[:hotels].length).to eq(2)
        expect(json_response[:total]).to eq(2)
      end

      it 'formats hotel data correctly' do
        post '/api/hotels/search', params: { location: 'Hollywood' }
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        first_hotel = json_response[:hotels].first
        expect(first_hotel[:id]).to eq(101)
        expect(first_hotel[:name]).to eq('Oceanfront Villa')
        expect(first_hotel[:location]).to eq('Hollywood')
        expect(first_hotel[:bedrooms]).to eq(4)
        expect(first_hotel[:bathrooms]).to eq(3)
        expect(first_hotel[:guests]).to eq(8)
      end

      it 'extracts images from pictures array' do
        post '/api/hotels/search', params: { location: 'Hollywood' }
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        first_hotel = json_response[:hotels].first
        expect(first_hotel[:image]).to eq('https://example.com/villa-large.jpg')
        
        second_hotel = json_response[:hotels].second
        expect(second_hotel[:image]).to be_nil
      end
    end

    context 'without location parameter' do
      it 'returns bad request error' do
        post '/api/hotels/search', params: {}
        
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:error]).to eq('Location is required')
      end
    end

    context 'when BoomNow API returns error' do
      before do
        stub_request(:get, %r{#{base_url}/listings\?.*})
          .with(headers: { 'Authorization' => "Bearer #{access_token}" })
          .to_return(status: 400, body: { error: 'Bad Request' }.to_json)
      end

      it 'returns error' do
        post '/api/hotels/search', params: { location: 'Hollywood' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:error]).to be_present
      end
    end
  end
end

