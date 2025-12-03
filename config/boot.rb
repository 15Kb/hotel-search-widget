ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Require standard library gems for Ruby 2.7+ compatibility
require 'logger'
require 'base64'
require 'bigdecimal'
require 'mutex_m'
