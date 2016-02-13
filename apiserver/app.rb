require 'byebug'

require 'json'
require 'sinatra'
require 'sinatra-websocket'
require 'sinatra/cross_origin'
require 'mongo'

configure do
  enable :cross_origin
end

require './models/device'

before '/api/*' do
  content_type :json
end

options "*" do
  response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end

[
  ['devices', Device],
  ['algorithms'],
  ['interfaces'],
].each do |model|

  model_class = model[1]
  model = model[0]

  get "/api/v1/#{model}" do
    @records = model_class.all

    erb :'api/models/index'
  end

  get "/api/v1/#{model}/:hwid" do |id|
    Device.get hwid
  end

  post "/api/v1/#{model}" do
    params = JSON.parse(request.body.read)

    Device.create params["data"]["attributes"]

    params.to_json
  end

  delete "/api/v1/#{model}/:id" do |id|
    Device.delete id
    {meta:{}}.to_json
  end

  put '/api/v1/#{model}/:hwid' do |hwid|
    params.delete "captures"
    params.delete "splat"

    Device.update hwid, params
  end

end

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['API_SERVER_PORT']
set :bind, '0.0.0.0'

Device.init settings.db
