require 'bundler'
Bundler.require

require './app'

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

run Sinatra::Application
