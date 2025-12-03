# Hotel Search Widget

A modern hotel search widget built with Ruby on Rails backend and React frontend, integrating with the BoomNow API to search and display hotel listings.

![Ruby](https://img.shields.io/badge/Ruby-2.7.4-red)
![Rails](https://img.shields.io/badge/Rails-6.0.6.1-red)
![React](https://img.shields.io/badge/React-17.0.1-blue)
![Node](https://img.shields.io/badge/Node-14.15.1-green)
![Tests](https://img.shields.io/badge/Tests-50_passing-brightgreen)

## Features

### Backend
- ✅ Used boilerplate from https://github.com/giannisp/rails-react-boilerplate
- ✅ Ruby on Rails 6.0.6.1 API
- ✅ BoomNow API integration (OAuth authentication, hotel search, city listings)
- ✅ RESTful API endpoints
- ✅ Service layer architecture
- ✅ Comprehensive RSpec test suite (23 tests)

### Frontend
- ✅ React 17.x with Hooks
- ✅ Autocomplete city search with dropdown
- ✅ Real-time hotel search results
- ✅ Responsive design with modern UI
- ✅ Error handling and loading states
- ✅ Jest + React Testing Library tests (27 tests)

### Design
- 🎨 Purple gradient background
- 📱 Mobile-responsive layout
- 🎯 Clean, modern card-based design
- ⚡ Fast and intuitive user experience

## Tech Stack

### Backend
- **Ruby** 2.7.4
- **Rails** 6.0.6.1
- **Bundler** 2.4.22
- **RSpec** 5.1 (testing)
- **WebMock** 3.26 (API mocking)
- **VCR** 6.3 (API interaction recording)

### Frontend
- **React** 17.0.1
- **Axios** 0.21.1 (HTTP client)
- **Webpack** 4.44.2
- **Babel** 7.x
- **SASS/SCSS** for styling
- **Jest** 27.5.1 (testing)
- **React Testing Library** 12.1.5

## Prerequisites

- Ruby 2.7.4
- Node.js 14.15.1
- PostgreSQL 14+ (optional - DB connection disabled)
- npm or yarn

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd hotel-search-widget
```

### 2. Install Ruby dependencies

```bash
# Install bundler if not available
gem install bundler

# Install gems
bundle install
```

### 3. Install Node dependencies

```bash
npm install
```

### 4. Set up environment variables (optional)

Create a `.env` file in the root directory:

```bash
BOOMNOW_CLIENT_ID=your_client_id
BOOMNOW_CLIENT_SECRET=your_client_secret
BOOMNOW_API_URL=https://app.boomnow.com/open_api/v1
```

Default credentials are configured in `config/initializers/boomnow.rb`.

### 5. Build frontend assets

```bash
npm run webpack
```

### 6. Start the Rails server

```bash
bundle exec rails s
```

Visit **http://localhost:3000** to see the application.

## Development

### Build assets in watch mode

For automatic rebuilding on file changes:

```bash
npm run webpack:watch
```

### Run linters

```bash
# ESLint for JavaScript
npm run eslint

# Stylelint for SCSS (via webpack)
npm run webpack
```

## Testing

### Backend Tests (RSpec)

```bash
# Run all backend tests
bundle exec rspec

# Run with detailed output
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/services/boom_now_service_spec.rb
```

**Test Coverage:**
- ✅ 23 RSpec tests
- Service layer tests (BoomNowService)
- Controller tests (Api::HotelsController)
- Request/Integration tests

### Frontend Tests (Jest)

```bash
# Run all frontend tests
npm test

# Run in watch mode
npm run test:watch

# Run with coverage report
npm run test:coverage
```

**Test Coverage:**
- ✅ 27 Jest tests
- Component rendering tests
- User interaction tests
- API integration tests
- Error handling tests

### Combined Test Results

```
Backend:  23 passing tests
Frontend: 27 passing tests
Total:    50 passing tests ✨
```

## API Endpoints

### GET `/api/hotels/cities`

Fetches list of available cities.

**Response:**
```json
{
  "cities": ["Hollywood", "Miami", "Fort Lauderdale", ...]
}
```

### POST `/api/hotels/search`

Searches for hotels in a specified location.

**Request:**
```json
{
  "location": "Hollywood"
}
```

**Response:**
```json
{
  "hotels": [
    {
      "id": 1,
      "name": "Luxury Beach Villa",
      "location": "Hollywood, Florida",
      "price": "$450 per night",
      "image": "https://example.com/image.jpg",
      "rating": 4.8,
      "description": "Beautiful oceanfront villa",
      "bedrooms": 4,
      "bathrooms": 3,
      "guests": 8,
      "amenities": ["WiFi", "Pool", "Kitchen"]
    }
  ],
  "total": 1,
  "page": 1,
  "per_page": 50
}
```

## Project Structure

```
hotel-search-widget/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   └── hotels_controller.rb    # API endpoints
│   │   └── home_controller.rb
│   ├── services/
│   │   └── boom_now_service.rb         # BoomNow API integration
│   └── views/
│       └── home/
│           └── index.html.erb          # Main page
├── config/
│   ├── initializers/
│   │   └── boomnow.rb                  # BoomNow configuration
│   └── routes.rb                       # API routes
├── front/
│   ├── js/
│   │   ├── components/
│   │   │   ├── App.js                  # Root component
│   │   │   ├── HotelSearch.js          # Main search widget
│   │   │   ├── SearchForm.js           # Search input with autocomplete
│   │   │   └── SearchResults.js        # Results display
│   │   └── utils/
│   │       └── logger.js               # Logging utility
│   └── css/
│       └── app.scss                    # Styles
├── spec/                               # Backend tests
│   ├── controllers/
│   ├── requests/
│   ├── services/
│   └── support/
└── front/js/                           # Frontend tests
    └── components/
        ├── App.test.js
        ├── HotelSearch.test.js
        ├── SearchForm.test.js
        └── SearchResults.test.js
```

## Configuration

### BoomNow API Configuration

Edit `config/initializers/boomnow.rb`:

```ruby
module BoomNow
  CONFIG = {
    client_id: ENV.fetch('BOOMNOW_CLIENT_ID', 'your_default_client_id'),
    client_secret: ENV.fetch('BOOMNOW_CLIENT_SECRET', 'your_default_secret'),
    api_url: ENV.fetch('BOOMNOW_API_URL', 'https://app.boomnow.com/open_api/v1')
  }.freeze
end
```

### Database Configuration

Database connection is **disabled by default** (Active Record not loaded). To enable:

1. Uncomment `require 'rails/all'` in `config/application.rb`
2. Remove selective framework requires
3. Uncomment Active Record configurations in environment files
4. Run `rails db:create` and `rails db:migrate`

## Production Deployment

### 1. Build production assets

```bash
npm run webpack:production
```

### 2. Set environment variables

```bash
export SECRET_KEY_BASE=your_secret_key
export RAILS_SERVE_STATIC_FILES=true
export BOOMNOW_CLIENT_ID=your_client_id
export BOOMNOW_CLIENT_SECRET=your_client_secret
```

### 3. Run in production mode

```bash
rails s -e production
```

### Docker Deployment (Optional)

```bash
# Build assets first
npm run webpack:production

# Build Docker image
docker build -t hotel-search-widget .

# Run container
docker run -p 3000:3000 \
  -e SECRET_KEY_BASE=your_secret_key \
  -e BOOMNOW_CLIENT_ID=your_client_id \
  -e BOOMNOW_CLIENT_SECRET=your_client_secret \
  hotel-search-widget
```

## BoomNow API Integration

### Authentication

The application automatically authenticates with BoomNow API using OAuth:

```ruby
POST https://app.boomnow.com/open_api/v1/auth/token
Content-Type: application/json

{
  "client_id": "your_client_id",
  "client_secret": "your_client_secret"
}
```

Returns Bearer token used for subsequent requests.

### Hotel Search

```ruby
GET https://app.boomnow.com/open_api/v1/listings?city=Hollywood&adults=2&children=0&page=1
Authorization: Bearer <token>
```

### City Listings

```ruby
GET https://app.boomnow.com/open_api/v1/listings/cities
Authorization: Bearer <token>
```

## Features in Detail

### Autocomplete City Search
- Real-time filtering of available cities
- Keyboard navigation (Arrow keys, Enter, Escape)
- Click to select from dropdown
- Loading states

### Hotel Results
- Card-based layout
- Hotel images with fallback
- Location, price, rating display
- Amenities (bedrooms, bathrooms, guests)
- Responsive grid layout

### Error Handling
- API error messages displayed to user
- Graceful fallbacks for missing data
- Loading states during API calls

## Troubleshooting

### Port 3000 already in use

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Then restart server
bundle exec rails s
```

### Webpack build fails

```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install

# Rebuild assets
npm run webpack
```

### Tests failing

```bash
# Clear test caches
npx jest --clearCache
bundle exec rspec --only-failures

# Reinstall dependencies
bundle install
npm install
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available as open source under the terms of the MIT License.

## Acknowledgments

- BoomNow API for hotel listings data
- React and Rails communities for excellent documentation
- Contributors and testers

## Support

For issues, questions, or contributions, please open an issue on GitHub.

---

Built with ❤️ using Ruby on Rails and React
