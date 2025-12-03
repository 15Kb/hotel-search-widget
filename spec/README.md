# Test Suite Documentation

## Overview

This project uses RSpec for testing with WebMock for HTTP request stubbing and VCR for recording API interactions.

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with detailed output
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/services/boom_now_service_spec.rb

# Run specific test by line number
bundle exec rspec spec/services/boom_now_service_spec.rb:25
```

## Test Coverage

### 1. BoomNowService Tests (`spec/services/boom_now_service_spec.rb`)

Tests the BoomNow API integration service:

- **Authentication**
  - Successfully authenticates with BoomNow API
  - Sets token expiration time correctly
  - Handles authentication failures

- **Fetch Cities**
  - Fetches cities from BoomNow API
  - Returns error hash when API fails

- **Search Hotels**
  - Searches hotels by location with proper parameters
  - Includes pagination information
  - Handles errors gracefully

### 2. Api::HotelsController Tests (`spec/controllers/api/hotels_controller_spec.rb`)

Tests the API controller endpoints:

- **GET #cities**
  - Returns list of cities when successful
  - Returns empty array when service returns error
  - Handles service exceptions gracefully

- **POST #search**
  - Returns formatted hotel results with valid location
  - Formats hotel images from pictures array
  - Includes pagination info
  - Returns bad request error without location parameter
  - Returns unprocessable entity on service error
  - Returns internal server error on exceptions

### 3. Request Specs (`spec/requests/api/hotels_spec.rb`)

Integration tests for the full HTTP request/response cycle:

- **GET /api/hotels/cities**
  - Returns list of available cities

- **POST /api/hotels/search**
  - Returns search results with valid location
  - Formats hotel data correctly from BoomNow API
  - Extracts images from pictures array (large, regular, original, thumbnail)
  - Returns bad request without location parameter
  - Handles BoomNow API errors appropriately

## Test Tools

### WebMock
Used to stub HTTP requests to prevent actual API calls during testing:

```ruby
stub_request(:post, "https://app.boomnow.com/open_api/v1/auth/token")
  .to_return(status: 201, body: { access_token: 'token' }.to_json)
```

### VCR
Configured to record and replay HTTP interactions:

- Cassettes stored in `spec/vcr_cassettes/`
- Sensitive data (client_id, client_secret, access_token) automatically filtered
- Configure per-test with RSpec metadata: `it "test", :vcr do`

## Test Data

All tests use realistic test data matching the BoomNow API structure:

- **Listings** include: id, title, city_name, beds, baths, accommodates, pictures, amenities
- **Pictures** array with: large, regular, original, thumbnail URLs
- **Pagination** info: count, page, per_page

## Configuration Files

- `spec/rails_helper.rb` - Rails-specific test configuration
- `spec/spec_helper.rb` - General RSpec configuration
- `spec/support/vcr.rb` - VCR configuration for API recording

## Best Practices

1. **Stub external API calls** - Never make real API calls in tests
2. **Test edge cases** - Include tests for errors and edge conditions
3. **Use realistic data** - Match actual API response structures
4. **Keep tests fast** - All tests run in under 1 second
5. **Test behavior, not implementation** - Focus on what the code does, not how

## Test Statistics

- **Total Examples**: 23
- **Total Failures**: 0
- **Test Coverage**:
  - Service Layer: BoomNowService
  - Controller Layer: Api::HotelsController
  - Integration Layer: Full request/response cycle

