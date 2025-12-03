/**
 * @file SearchResults component - Display search results.
 */

import React from 'react';
import PropTypes from 'prop-types';

const SearchResults = ({ results }) => {
  if (!results || results.length === 0) {
    return (
      <div className="search-results">
        <p className="no-results">No hotels found. Try a different location.</p>
      </div>
    );
  }

  return (
    <div className="search-results">
      <h2 className="results-title">
        Found {results.length} {results.length === 1 ? 'hotel' : 'hotels'}
      </h2>
      <div className="results-grid">
        {results.map((hotel) => (
          <div key={hotel.id || hotel.name} className="hotel-card">
            {hotel.image && (
              <div className="hotel-image">
                <img src={hotel.image} alt={hotel.name || 'Hotel'} />
              </div>
            )}
            <div className="hotel-content">
              <h3 className="hotel-name">{hotel.name}</h3>
              {hotel.location && (
                <p className="hotel-location">📍 {hotel.location}</p>
              )}
              <div className="hotel-amenities">
                {hotel.bedrooms && (
                  <span className="amenity">🛏️ {hotel.bedrooms} bed</span>
                )}
                {hotel.bathrooms && (
                  <span className="amenity">🚿 {hotel.bathrooms} bath</span>
                )}
                {hotel.guests && (
                  <span className="amenity">👥 {hotel.guests} guests</span>
                )}
              </div>
              {hotel.rating && (
                <p className="hotel-rating">⭐ {hotel.rating}</p>
              )}
              {hotel.description && (
                <p className="hotel-description">{hotel.description}</p>
              )}
              <p className="hotel-price">{hotel.price}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

SearchResults.propTypes = {
  results: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
      name: PropTypes.string,
      location: PropTypes.string,
      price: PropTypes.string,
      image: PropTypes.string,
      rating: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
      description: PropTypes.string,
      bedrooms: PropTypes.number,
      bathrooms: PropTypes.number,
      guests: PropTypes.number,
    }),
  ),
};

SearchResults.defaultProps = {
  results: null,
};

export default SearchResults;
