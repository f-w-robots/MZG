require 'byebug'

require 'bundler'
Bundler.require

require 'tilt/erb'

require 'json'
require_relative 'models/mailer'

require 'bcrypt'

$LOAD_PATH.push File.expand_path('../routes', __FILE__)
%w{ tmp config auth }.each { |file| require file }

require_relative 'helpers/helpers'

class App < Sinatra::Base
  helpers Sinatra::Cookies
  enable :sessions
  set :session_secret, ENV['SECRET']
  use Rack::Session::Cookie, secret: ENV['SECRET']

  MODELS = %w{ algorithm device }
  $LOAD_PATH.push File.expand_path('../models', __FILE__)
  (MODELS+['user']).each { |model_name| require model_name }

  set :root, File.dirname(__FILE__)
  Mongoid.load!("mongoid.yml", App.environment)
  set :port, ENV['API_SERVER_PORT']
  set :bind, '0.0.0.0'

  set :mailer, Mailer.new(ENV['SYS_EMAIL_ADDRESS'])

  set :protection, :except => :json_csrf

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

  options "/auth/*" do
    response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT, PATCH,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    200
  end

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.where('_id' => id).first }

    config.scope_defaults :default,
      strategies: [:password],
      action: 'auth/unauthenticated'

    config.failure_app = self
  end

  require './warden'

  OmniAuth.config.full_host = ENV["AUTH_REDIRECT"]

  use OmniAuth::Builder do
    provider :github, ENV['AUTH_GITHUB_KEY'], ENV['AUTH_GITHUB_SECRET'], scope: "user"
  end

  helpers Sinatra::App::Helpers

  register Sinatra::App::Routing::Tmp
  register Sinatra::App::Routing::Config
  register Sinatra::App::Routing::Auth
  register Sinatra::CrossOrigin

  enable :cross_origin
  Mongo::Logger.logger.level = ::Logger::FATAL
end
