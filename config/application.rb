require_relative 'boot'
Bundler.require :default
require 'goliath'
if Goliath.env?('development')
  require 'dotenv'
  Dotenv.load!
end

Bundler.require Goliath.env
INTERVAL = ENV['INTERVAL'].to_i > 0 ? ENV['INTERVAL'].to_i : 30
Dir[File.expand_path('../../config/initializers/*.rb', __FILE__)].each do |file|
  require file
end
