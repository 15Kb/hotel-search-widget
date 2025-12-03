require 'rails_helper'

RSpec.describe BoomNowService, type: :service do
  let(:service) { described_class.new }
  let(:base_url) { 'https://app.boomnow.com/open_api/v1' }
  let(:client_id) { 'boom_3a213702291c3df84814' }
  let(:client_secret) { '76df8d0d9bf2a21b04b4a64504c1107ed9b4078b3a3b1fd722687a9f399e7c76' }
  let(:access_token) { 'test_access_token_123' }

  describe '#authenticate' do
    let(:auth_url) { "#{base_url}/auth/token" }
    let(:auth_response) do
      {
        token_type: 'Bearer',
        expires_in: 3600,
        access_token: access_token
      }
    end

    before do
      stub_request(:post, auth_url)
        .with(
          body: {
            client_id: client_id,
            client_secret: client_secret
          }.to_json,
          headers: {
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 201,
          body: auth_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'successfully authenticates with BoomNow API' do
      service.send(:authenticate)
      expect(service.instance_variable_get(:@access_token)).to eq(access_token)
    end

    it 'sets token expiration time' do
      before_time = Time.now
      service.send(:authenticate)
      token_expiration = service.instance_variable_get(:@token_expires_at)
      expect(token_expiration).to be > before_time
      expect(token_expiration).to be <= (before_time + 3601)
    end

    context 'when authentication fails' do
      before do
        stub_request(:post, auth_url)
          .to_return(status: 401, body: { error: 'Invalid credentials' }.to_json)
      end

      it 'raises an error' do
        expect { service.send(:authenticate) }.to raise_error(/Authentication failed/)
      end
    end
  end

  describe '#fetch_cities' do
    let(:cities_url) { "#{base_url}/listings/cities" }
    let(:cities_response) do
      {
        cities: ['Hollywood', 'Miami', 'Los Angeles', 'New York']
      }
    end

    before do
      service.instance_variable_set(:@access_token, access_token)
      service.instance_variable_set(:@token_expires_at, Time.now + 3600)
      
      stub_request(:get, cities_url)
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(
          status: 200,
          body: cities_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'fetches cities from BoomNow API' do
      result = service.fetch_cities
      expect(result[:cities]).to eq(['Hollywood', 'Miami', 'Los Angeles', 'New York'])
    end

    it 'returns error hash on error' do
      stub_request(:get, cities_url)
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(status: 500, body: 'Internal Server Error')
      result = service.fetch_cities
      expect(result[:error]).to be_present
      expect(result[:cities]).to eq([])
    end
  end

  describe '#search_hotels' do
    let(:listings_url) { "#{base_url}/listings?city=Hollywood&adults=2&children=0&page=1" }
    let(:listings_response) do
      {
        listings: [
          {
            id: 1,
            title: 'Beach House',
            city_name: 'Hollywood',
            beds: 3,
            baths: 2,
            accommodates: 6,
            pictures: [
              { large: 'https://example.com/image1.jpg' }
            ]
          }
        ],
        pagi_info: {
          count: 1,
          page: 1,
          per_page: 50
        }
      }
    end

    before do
      service.instance_variable_set(:@access_token, access_token)
      service.instance_variable_set(:@token_expires_at, Time.now + 3600)
      
      stub_request(:get, listings_url)
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(
          status: 200,
          body: listings_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'searches hotels by location' do
      result = service.search_hotels(location: 'Hollywood')
      expect(result[:listings]).to be_an(Array)
      expect(result[:listings].first[:title]).to eq('Beach House')
    end

    it 'includes pagination info' do
      result = service.search_hotels(location: 'Hollywood')
      expect(result[:pagi_info]).to be_present
      expect(result[:pagi_info][:count]).to eq(1)
    end

    it 'handles errors gracefully' do
      stub_request(:get, listings_url)
        .with(headers: { 'Authorization' => "Bearer #{access_token}" })
        .to_return(status: 500, body: 'Internal Server Error')
      result = service.search_hotels(location: 'Hollywood')
      expect(result[:error]).to be_present
    end
  end
end

