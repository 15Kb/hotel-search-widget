# BoomNow API Configuration
module BoomNow
  CONFIG = {
    client_id: ENV.fetch('BOOMNOW_CLIENT_ID', 'boom_3a213702291c3df84814'),
    client_secret: ENV.fetch('BOOMNOW_CLIENT_SECRET', '76df8d0d9bf2a21b04b4a64504c1107ed9b4078b3a3b1fd722687a9f399e7c76'),
    api_url: ENV.fetch('BOOMNOW_API_URL', 'https://app.boomnow.com/open_api/v1')
  }.freeze
end

