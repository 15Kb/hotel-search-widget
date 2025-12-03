/**
 * @file HotelSearch component - Main search widget.
 */

import React, { useState } from 'react';
import axios from 'axios';
import SearchForm from './SearchForm';
import SearchResults from './SearchResults';

const HotelSearch = () => {
  const [searchResults, setSearchResults] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSearch = async (searchParams) => {
    setIsLoading(true);
    setError(null);

    try {
      // eslint-disable-next-line no-console
      console.log('Searching for:', searchParams);

      const response = await axios.post('/api/hotels/search', searchParams);

      if (response.data.error) {
        setError(response.data.error);
        setSearchResults(null);
      } else {
        setSearchResults(response.data.hotels || []);
      }
    } catch (err) {
      const errorMessage =
        err.response?.data?.error ||
        err.response?.data?.message ||
        'Failed to search hotels. Please try again.';
      setError(errorMessage);
      setSearchResults(null);
      // eslint-disable-next-line no-console
      console.error('Search error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="hotel-search-widget">
      <div className="search-container">
        <h1 className="search-title">Find Your Perfect Hotel</h1>
        <SearchForm onSearch={handleSearch} isLoading={isLoading} />

        {error && <div className="error-message">{error}</div>}

        {searchResults && <SearchResults results={searchResults} />}
      </div>
    </div>
  );
};

export default HotelSearch;
