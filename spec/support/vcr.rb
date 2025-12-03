require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
  
  # Filter sensitive data
  config.filter_sensitive_data('<BOOMNOW_CLIENT_ID>') { BoomNow::CONFIG[:client_id] }
  config.filter_sensitive_data('<BOOMNOW_CLIENT_SECRET>') { BoomNow::CONFIG[:client_secret] }
  config.filter_sensitive_data('<ACCESS_TOKEN>') do |interaction|
    if interaction.response.headers['Content-Type']&.first&.include?('json')
      begin
        JSON.parse(interaction.response.body)['access_token']
      rescue
        nil
      end
    end
  end
end

