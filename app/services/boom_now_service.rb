# Service to interact with BoomNow API
require 'net/http'
require 'json'
require 'uri'

class BoomNowService
  BASE_URL = BoomNow::CONFIG[:api_url]
  CLIENT_ID = BoomNow::CONFIG[:client_id]
  CLIENT_SECRET = BoomNow::CONFIG[:client_secret]

  def initialize
    @access_token = nil
    @token_expires_at = nil
  end

  # Fetch all available cities
  # GET https://app.boomnow.com/open_api/v1/listings/cities
  # Headers: Authorization: Bearer {token}
  def fetch_cities
    ensure_authenticated!

    uri = URI("#{BASE_URL}/listings/cities")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@access_token}"

    Rails.logger.info("GET #{uri}")

    response = execute_request(uri, request)
    result = parse_response(response)
    
    Rails.logger.info("✓ Successfully fetched #{result[:cities]&.length || 0} cities")
    result
  rescue StandardError => e
    Rails.logger.error("✗ BoomNow API Error fetching cities: #{e.message}")
    { error: 'Failed to fetch cities', message: e.message, cities: [] }
  end

  # Search for hotels/listings based on location
  # GET https://app.boomnow.com/open_api/v1/listings
  # Query params: city, check_in, check_out, adults, children, bedrooms, bathrooms, page
  # Headers: Authorization: Bearer {token}
  def search_hotels(location:, check_in: nil, check_out: nil, adults: 2, children: 0)
    ensure_authenticated!

    # Build query parameters for BoomNow listings endpoint
    params = {
      city: location,
      adults: adults,
      children: children,
      page: 1
    }
    
    # Add check-in/check-out dates if provided
    params[:check_in] = check_in if check_in
    params[:check_out] = check_out if check_out

    # Build URL with query parameters
    query_string = URI.encode_www_form(params)
    uri = URI("#{BASE_URL}/listings?#{query_string}")
    
    # Create GET request (not POST!)
    request = Net::HTTP::Get.new(uri)
    # Set Bearer token in Authorization header as per BoomNow API spec
    request['Authorization'] = "Bearer #{@access_token}"

    Rails.logger.info("GET #{uri}")
    Rails.logger.info("Authorization: Bearer #{@access_token[0..10]}...") if @access_token
    Rails.logger.info("Search params: city=#{location}, adults=#{adults}, children=#{children}")

    response = execute_request(uri, request)
    result = parse_response(response)
    
    Rails.logger.info("✓ Successfully fetched #{result[:listings]&.length || 0} listings")
    result
  rescue StandardError => e
    Rails.logger.error("✗ BoomNow API Error: #{e.message}")
    Rails.logger.error("Backtrace: #{e.backtrace.first(5).join("\n")}")
    { error: 'Failed to search hotels', message: e.message }
  end

  private

  # Authenticate with BoomNow API and get access token
  # POST https://app.boomnow.com/open_api/v1/auth/token
  # Request: { client_id: string, client_secret: string }
  # Response: { token_type: "Bearer", expires_in: integer, access_token: string }
  def authenticate
    Rails.logger.info("Authenticating with BoomNow API...")
    
    uri = URI("#{BASE_URL}/auth/token")
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    
    request_body = {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET
    }
    request.body = request_body.to_json

    Rails.logger.info("POST #{uri}")
    Rails.logger.info("Request Body: #{request_body.to_json}")

    response = execute_request(uri, request)
    data = parse_response(response)

    Rails.logger.info("Auth response received: #{data.keys.join(', ')}")

    # BoomNow returns 'access_token' field
    if data[:access_token]
      @access_token = data[:access_token]
      @token_expires_at = Time.now + (data[:expires_in] || 3600).to_i
      Rails.logger.info("✓ Successfully authenticated with BoomNow API")
      Rails.logger.info("Token type: #{data[:token_type]}")
      Rails.logger.info("Token expires at: #{Time.at(data[:expires_in])}")
    else
      raise "Authentication failed: No access_token in response. Got: #{data.keys.join(', ')}"
    end
  rescue StandardError => e
    Rails.logger.error("✗ Authentication failed: #{e.message}")
    raise
  end

  # Ensure we have a valid access token
  def ensure_authenticated!
    if @access_token.nil? || token_expired?
      authenticate
    end
  end

  # Check if token is expired
  def token_expired?
    @token_expires_at.nil? || Time.now >= @token_expires_at
  end

  # Execute HTTP request
  def execute_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.read_timeout = 30
    http.open_timeout = 30
    http.request(request)
  end

  # Parse API response
  def parse_response(response)
    Rails.logger.info("Response status: #{response.code} #{response.message}")
    Rails.logger.info("Response body: #{response.body[0..500]}") # First 500 chars
    
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body, symbolize_names: true)
    when Net::HTTPUnauthorized
      error_data = JSON.parse(response.body) rescue {}
      error_msg = error_data['message'] || error_data['error'] || response.body
      raise "Authentication failed - #{error_msg}"
    when Net::HTTPBadRequest
      error_data = JSON.parse(response.body) rescue {}
      error_msg = error_data['message'] || error_data['error'] || response.body
      raise "Bad request: #{error_msg}"
    else
      error_data = JSON.parse(response.body) rescue {}
      error_msg = error_data['message'] || error_data['error'] || response.body
      raise "HTTP Error #{response.code}: #{error_msg}"
    end
  end
end
