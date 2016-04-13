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
require_relative 'bricks/group.rb'
require_relative 'bricks/proxy.rb'
require_relative 'bricks/control.rb'
require_relative 'bricks/algorithm.rb'
require_relative 'bricks/device.rb'

require_relative 'db/db.rb'
require_relative 'db/device.rb'
require_relative 'db/group.rb'

require_relative 'group_interface.rb'
require_relative 'device_manager.rb'
require_relative 'package_generator.rb'
require_relative 'logger.rb'

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  return if !request.websocket?

  settings.device_manager.open_socket request
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

get '/group/communicate/:name' do |name|
  group = settings.groups[name]
  return if !group
  group.start_interface request
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
  device = settings.device_manager.device(hwid)
  return '' if !device || !device.manual? || device.group_interface?

  response = device.interface.start(request)
  response
end

get '/:hwid' do |hwid|
  return if !request.websocket?
  puts "Connection from #{hwid}"

  bricks = Bricks.new hwid, settings.device_manager

  if settings.device_manager.device(hwid)
    settings.device_manager.device(hwid).destroy
  end

  device_record = DB::Device.new(hwid, settings.db)

  device = Device.new hwid, bricks
  bricks.push device

  if device_record.proxy?
    proxy_driver = device_record.proxy_driver
    proxy = Proxy.new(hwid, proxy_driver)
    bricks.push proxy
  end

  if device_record.group?
    group = settings.groups[device_record.group]
    if !group
      status 404
      return 'runned group not found'
    end
    bricks.push_group group
  end

  if device_record.manual?
    if !bricks.manual?
      backend = Control.new hwid
      bricks.push_interface backend
    end
  else
    backend = Algorithm.new hwid, device_record.algorithm
    backend.start request
    bricks.push backend
  end

  bricks.connect

  settings.device_manager.device_add(hwid, bricks)

  response = device.start request

  proxy.start if proxy

  response
end

set :devices, {}
set :groups, {}

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'

set :device_manager, DeviceManager.new

Mongo::Logger.logger.level = ::Logger::FATAL
