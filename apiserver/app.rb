require 'byebug'

require 'json'
require 'sinatra'
require 'sinatra/cross_origin'
require 'mongo'

require './models/device'
require './models/algorithm'
require './models/interface'

configure do
  enable :cross_origin
end

helpers do
  def attribute attr_name, attr, comma
    result = "\"#{attr_name}\": "
    if attr.is_a?(String)
      result += "\"#{attr.gsub('"', '\"').gsub("\n",'\n')}\""
    elsif attr.nil?
      result += '""'
    elsif attr.is_a?(Hash)
      result += attr.to_json
    else
      result += attr.to_s
    end
    result += ',' if comma
    result
  end
end

before '/api/*' do
  content_type :json
end

options "/api/*" do
  response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT, PATCH,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end

[
  Device,
  Algorithm,
  Interface,
].each do |model|
  get "/api/v1/#{model.pluralize}" do
    @records = model.all
    @attributes = model.attributes
    @model = model

    erb :'api/models/index'
  end

  get "/api/v1/#{model.pluralize}/:id" do |id|
    @records = model.get id
    @attributes = model.attributes
    @individual = true
    @model = model

    erb :'api/models/index'
  end

  post "/api/v1/#{model.pluralize}" do
    params = JSON.parse(request.body.read)
    attrs = params["data"]["attributes"]

    model.create attrs
    status 201
    {meta:{}}.to_json
  end

  delete "/api/v1/#{model.pluralize}/:id" do |id|
    model.delete id
    {meta:{}}.to_json
  end

  patch "/api/v1/#{model.pluralize}/:id" do |id|
    params = JSON.parse(request.body.read)
    model.update id, params["data"]["attributes"]

    {meta:{}}.to_json
  end

end

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['API_SERVER_PORT']
set :bind, '0.0.0.0'

Device.init settings.db
Algorithm.init settings.db
Interface.init settings.db
