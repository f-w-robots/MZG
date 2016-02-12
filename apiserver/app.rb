require 'byebug'

require 'json'
require 'sinatra'
require 'sinatra-websocket'
require 'mongo'

require './device'

before '/api/*' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Headers'] = "Origin, X-Requested-With, Content-Type, Accept"
  content_type :json
end

get '/api/v1/devices' do
  @devices = Device.all

  erb :'api/devices/index'
end

get '/api/v1/devices/:hwid' do |hwid|
  Device.get hwid
end

options '/api/v1/devices' do
  ''
end

post '/api/v1/devices' do
  params = JSON.parse(request.body.read)["data"]["attributes"]

  Device.create params

  @device = params

  erb :'api/devices/show'
end

delete '/api/v1/devices/:hwid' do |id|
  Device.delete hwid
end

put '/api/v1/devices/:hwid' do |hwid|
  params.delete "captures"
  params.delete "splat"

  Device.update hwid, params
end

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['API_SERVER_PORT']
set :bind, '0.0.0.0'

Device.init settings.db
