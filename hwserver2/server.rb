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

require_relative 'db/db.rb'
require_relative 'db/device.rb'
require_relative 'db/group.rb'

require_relative 'backends/algorithm.rb'
require_relative 'backends/control.rb'

require_relative 'device.rb'
require_relative 'device_for_group.rb'
require_relative 'control.rb'

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

  response = device.backend.start(request)
  response
end

get '/:hwid' do |hwid|
  return if !request.websocket?
  puts "Connection from #{hwid}"

  if settings.devices[hwid]
    settings.devices[hwid].close
  end

  device_record = DB::Device.new(hwid, settings.db)

  if device_record.group?
    group = settings.groups[device_record.group]
    return 'runned group not found' if !group
    device = DeviceForGroup.new hwid, device_record, group
  else
    device = Device.new hwid, device_record
  end
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
