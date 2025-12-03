/**
 * @file SearchForm component - Simple search form with location dropdown.
 */

import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import axios from 'axios';

const SearchForm = ({ onSearch, isLoading }) => {
  const [location, setLocation] = useState('');
  const [cities, setCities] = useState([]);
  const [filteredCities, setFilteredCities] = useState([]);
  const [showDropdown, setShowDropdown] = useState(false);
  const [loadingCities, setLoadingCities] = useState(true);

  // Fetch cities on component mount
  useEffect(() => {
    const fetchCities = async () => {
      try {
        const response = await axios.get('/api/hotels/cities');
        const cityList = response.data.cities || [];
        setCities(cityList);
        setFilteredCities(cityList);
        setLoadingCities(false);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Failed to fetch cities:', error);
        setLoadingCities(false);
      }
    };

    fetchCities();
  }, []);

  // Filter cities based on input
  useEffect(() => {
    if (location.trim() === '') {
      setFilteredCities(cities);
    } else {
      const filtered = cities.filter((city) =>
        city.toLowerCase().includes(location.toLowerCase()),
      );
      setFilteredCities(filtered);
    }
  }, [location, cities]);

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!location.trim()) {
      return;
    }

    setShowDropdown(false);
    onSearch({ location: location.trim() });
  };

  const handleInputChange = (e) => {
    setLocation(e.target.value);
    setShowDropdown(true);
  };

  const handleCitySelect = (city) => {
    setLocation(city);
    setShowDropdown(false);
  };

  const handleInputFocus = () => {
    setShowDropdown(true);
  };

  const handleInputBlur = () => {
    // Delay to allow click on dropdown item
    setTimeout(() => setShowDropdown(false), 200);
  };

  return (
    <form className="search-form" onSubmit={handleSubmit}>
      <div className="form-content">
        <div className="form-field">
          {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
          <label htmlFor="location" className="form-label">
            Location
          </label>
          <div className="autocomplete-wrapper">
            <input
              id="location"
              type="text"
              className="form-input"
              placeholder={
                loadingCities ? 'Loading cities...' : 'Select or enter city'
              }
              value={location}
              onChange={handleInputChange}
              onFocus={handleInputFocus}
              onBlur={handleInputBlur}
              disabled={isLoading || loadingCities}
              autoComplete="off"
            />
            {showDropdown && filteredCities.length > 0 && (
              <div className="autocomplete-dropdown">
                {filteredCities.slice(0, 10).map((city) => (
                  <div
                    key={city}
                    className="autocomplete-item"
                    onClick={() => handleCitySelect(city)}
                    role="button"
                    tabIndex={0}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') handleCitySelect(city);
                    }}
                  >
                    📍 {city}
                  </div>
                ))}
                {filteredCities.length > 10 && (
                  <div className="autocomplete-more">
                    +{filteredCities.length - 10} more cities...
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        <button type="submit" className="search-button" disabled={isLoading}>
          {isLoading ? 'Searching...' : 'Search'}
        </button>
      </div>
    </form>
  );
};

SearchForm.propTypes = {
  onSearch: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
};

export default SearchForm;
