require 'byebug'

require 'bundler'
Bundler.require

require 'json'

$LOAD_PATH.push File.expand_path('../routes', __FILE__)
%w{ config auth }.each { |file| require file }

require_relative 'helpers/helpers'

class App < Sinatra::Base
  helpers Sinatra::Cookies
  enable :sessions
  set :session_secret, ENV['SECRET']
  use Rack::Session::Cookie, secret: ENV['SECRET']

  MODELS = %w{ algorithm device group interface}
  $LOAD_PATH.push File.expand_path('../models', __FILE__)
  (MODELS+['user']).each { |model_name| require model_name }

  Mongo::Logger.logger.level = ::Logger::FATAL
  set :root, File.dirname(__FILE__)
  set :db,  Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
  set :port, ENV['API_SERVER_PORT']
  set :bind, '0.0.0.0'

  require './migration'
  migrate db

  before '/api/*' do
    content_type :json
  end

  before '/api/*' do
    @user = env['warden'].user
    # halt "{\"data\":[]}" if !@user
  end

  options "/api/*" do
    response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT, PATCH,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    200
  end

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      strategies: [:password],
      action: 'auth/unauthenticated'

    config.failure_app = self
  end

  User.init db
  use OmniAuth::Builder do
    provider :vkontakte, ENV['AUTH_API_KEY'], ENV['AUTH_API_SECRET']
  end

  helpers Sinatra::App::Helpers

  register Sinatra::App::Routing::Config
  register Sinatra::App::Routing::Auth
  register Sinatra::CrossOrigin

  enable :cross_origin

  Mongo::Logger.logger.level = ::Logger::FATAL
end
