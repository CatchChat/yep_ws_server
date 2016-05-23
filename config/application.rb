require_relative 'boot'
require 'dotenv'
Dotenv.load!
INTERVAL = ENV['INTERVAL'].to_i > 0 ? ENV['INTERVAL'].to_i : 30

Bundler.require :default
require 'goliath'
Bundler.require Goliath.env

Dir[File.expand_path('../../config/initializers/*.rb', __FILE__)].each do |file|
  require file
end
