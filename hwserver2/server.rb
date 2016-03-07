# Server for devices
#
# Accepts connections from devices by web-sockets
# and control devices through the connections
#
require 'byebug'
Thread::abort_on_exception = true

require 'json'
require 'sinatra'
require 'sinatra-websocket'
require 'mongo'

module DB end
require_relative 'db/device.rb'

require_relative 'backends/algorithm.rb'
require_relative 'backends/control.rb'

require_relative 'device.rb'
require_relative 'control.rb'

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.devices.keys}.to_json
end

get '/control/:hwid' do |hwid|
  device = settings.devices[hwid]
  return '' if !device || !device.manual?

  response = device.backend.start(request)
  response
end

get '/:hwid' do |hwid|
  puts "Connection from #{hwid}"

  if settings.devices[hwid]
    settings.devices[hwid].close
  end

  db = DB::Device.new(hwid, settings.db)

  device = Device.new hwid, db
  response = device.start request

  settings.devices[hwid] = device

  response
end

set :devices, {}
set :groups, {}

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'

Mongo::Logger.logger.level = ::Logger::FATAL
