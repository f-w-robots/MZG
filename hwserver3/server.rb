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

require_relative 'bricks/bricks.rb'
require_relative 'bricks/brick.rb'
require_relative 'bricks/control.rb'
require_relative 'bricks/algorithm.rb'
require_relative 'bricks/device.rb'

require_relative 'db/db.rb'
require_relative 'db/device.rb'
require_relative 'db/group.rb'

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.devices.map{|k,v|v.manual? ? k : nil}.reject{|v|!v}}.to_json
end

get '/group/info/:name' do |name|
  response.headers['Access-Control-Allow-Origin'] = '*'
  group = settings.groups[name]
  if !group
    status 404
  else
    group.options[:info].to_s
  end
end

post '/group/up/:name' do |name|
  response.headers['Access-Control-Allow-Origin'] = '*'
  group_db = DB::Group.new name, settings.db

  group = group_db.class_const.new group_db

  if settings.groups[name]
    settings.groups[name].destroy
  end
  settings.groups[name] = group

  group.start
end

get '/control/:hwid' do |hwid|
  device = settings.devices[hwid]
  return '' if !device || !device.manual?

  response = device.interface.start(request)
  response
end

get '/:hwid' do |hwid|
  return if !request.websocket?
  puts "Connection from #{hwid}"

  bricks = Bricks.new hwid

  if settings.devices[hwid]
    settings.devices[hwid].destroy
  end

  device_record = DB::Device.new(hwid, settings.db)

  device = Device.new hwid, device_record.manual?
  bricks.push device

  if device_record.group?
    group = settings.groups[device_record.group]
    return 'runned group not found' if !group
    bricks.push group
  end

  if device_record.proxy?
    device = DeviceProxy.new device, device_record
  end

  if device_record.manual?
    backend = Control.new hwid
    bricks.push_interface backend
  else
    backend = Algorithm.new hwid, device_record.algorithm
    backend.start request
    bricks.push backend
  end

  bricks.connect

  settings.devices[hwid] = bricks

  device.start request
end

set :devices, {}
set :groups, {}

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'

Mongo::Logger.logger.level = ::Logger::FATAL
