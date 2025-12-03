# API controller for hotel search
module Api
  class HotelsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def cities
      service = BoomNowService.new
      result = service.fetch_cities

      if result[:error]
        render json: { cities: [] }, status: :ok
      else
        # Extract city names from the response
        cities = result[:cities] || []
        render json: { cities: cities }
      end
    rescue StandardError => e
      Rails.logger.error("Fetch cities error: #{e.message}")
      render json: { cities: [] }, status: :ok
    end

    def search
      location = params[:location]

      if location.blank?
        render json: { error: 'Location is required' }, status: :bad_request
        return
      end

      service = BoomNowService.new
      result = service.search_hotels(location: location)

      if result[:error]
        render json: result, status: :unprocessable_entity
      else
        render json: format_results(result)
      end
    rescue StandardError => e
      Rails.logger.error("Hotel search error: #{e.message}")
      render json: { error: 'Internal server error', message: e.message }, status: :internal_server_error
    end

    private

    def format_results(data)
      # BoomNow API returns 'listings' array
      listings = data[:listings] || []
      pagi_info = data[:pagi_info] || {}
      
      {
        hotels: listings.map do |listing|
          format_listing(listing)
        end,
        total: pagi_info[:count] || listings.count,
        page: pagi_info[:page] || 1,
        per_page: pagi_info[:per_page] || 50
      }
    end

    def format_listing(listing)
      {
        id: listing[:id],
        name: listing[:title] || listing[:nickname],
        location: listing[:city_name],
        price: format_price(listing),
        image: get_listing_image(listing),
        rating: listing[:rating],
        description: get_description(listing),
        bedrooms: listing[:beds],
        bathrooms: listing[:baths],
        guests: listing[:accommodates],
        amenities: listing[:amenities],
        lat: listing[:lat],
        lng: listing[:lng]
      }
    end

    def get_listing_image(listing)
      # BoomNow API returns 'pictures' array with image objects
      pictures = listing[:pictures]
      
      return nil if pictures.nil? || !pictures.is_a?(Array) || pictures.empty?
      
      # Get the first picture and extract URL
      # Pictures have: large, regular, original, thumbnail
      first_picture = pictures.first
      return nil unless first_picture.is_a?(Hash)
      
      # Prefer larger images, fallback to smaller
      first_picture[:large] || first_picture[:regular] || first_picture[:original] || first_picture[:thumbnail]
    end

    def get_description(listing)
      # Try to get description from marketing_content or other fields
      marketing = listing[:marketing_content]
      if marketing.is_a?(Hash)
        marketing[:description] || marketing[:summary]
      else
        listing[:description] || listing[:summary]
      end
    end

    def format_price(listing)
      # Try different price fields
      price = listing[:price] || listing[:rate] || listing[:nightly_rate] || 
              listing[:base_rate] || listing[:price_per_night]
      
      return 'Price on request' if price.nil?

      if price.is_a?(Hash)
        amount = price[:amount] || price[:value] || price[:total]
        currency = price[:currency] || 'USD'
        "$#{amount} #{currency}/night"
      elsif price.is_a?(Numeric)
        "$#{price}/night"
      else
        price.to_s
      end
    end
  end
end

