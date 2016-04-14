require 'byebug'

require 'json'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'mongo'

$LOAD_PATH.push File.expand_path('../routes', __FILE__)
%w{ config }.each { |file| require file }

require_relative 'helpers/helpers'


class App < Sinatra::Base
  MODELS = %w{ algorithm device group interface }
  $LOAD_PATH.push File.expand_path('../models', __FILE__)
  MODELS.each { |model_name| require model_name }

  set :root, File.dirname(__FILE__)
  set :db,  Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
  set :port, ENV['API_SERVER_PORT']
  set :bind, '0.0.0.0'

  before '/api/*' do
    content_type :json
  end

  options "/api/*" do
    response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT, PATCH,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    200
  end


  helpers Sinatra::App::Helpers
  register Sinatra::App::Routing::Config
  register Sinatra::CrossOrigin

  enable :cross_origin
end
