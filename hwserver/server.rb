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

require_relative 'algorithm_backend'
require_relative 'device_websocket'
require_relative 'manual_backend'
require_relative 'group_backend'

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.manual_hwsockets.keys}.to_json
end

get '/group/info/:name' do |name|
  response.headers['Access-Control-Allow-Origin'] = '*'
  group = settings.groups[name]
  if !group
    status 404
    return
  end
  group.options[:info].to_s
end

def run_group record
  class_name = "Group#{record['id'].to_s}"
  code = record[:code]
  if code.start_with?('#file:')
    code = open(code.gsub('#file:','').strip).read
  end
  eval "class #{class_name}
    #{code}
  end"
  Kernel.const_get(class_name).new(settings.hwsockets, record)
end

post '/group/up/:name' do |name|
  response.headers['Access-Control-Allow-Origin'] = '*'
  record = settings.db[:groups].find(name: name).first
  # create class from db
  group = settings.groups[name]
  group.destroy if group
  group = run_group(record)
  if !settings.groups[name]
    settings.groups[name] = group
  else
    settings.groups[name].destroy
    settings.groups[name] = group
  end
  group.start
end

get '/control/:hwid' do |hwid|
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

  if !record['group'].nil? && !record['group'].empty?
    name = record['group']
    group = settings.groups[name]
    return if !group
  end

  request.websocket do |ws|
    ws.onopen do
      settings.swsockets[hwid] = ws
    end
    ws.onmessage do |msg|
      hwsocket = settings.manual_hwsockets[hwid]
      if hwsocket
        hwsocket.on_message(msg)
      end
    end
    ws.onclose do
      settings.swsockets.delete(hwid)
    end
  end
end

def attach_to_group socket, group_name
  record = settings.db[:games].find(name: group_name).first
  group = settings.groups[group_name]
  return nil if !group
  return DeviceWebSocketForGroup.new socket, group, group_name
end

class ProxyBackend
  def initialize backend, processor
    @backend = backend
    # @processor = processor.new self
  end

  def on_open socket
    @backend.on_open socket
  end

  def on_message msg
    @backend.on_message msg
  end

  def on_close
    @backend.on_close
  end

  def getSendMessagePermission!
    @backend.getSendMessagePermission!
  end

  def send_direct msg
    @backend.send_direct msg
  end
end

def get_proxy_class record
  hwid = record['hwid']
  algorithm_record = settings.db[:algorithms].find(:'algorithm-id' => record['proxy-id']).first
  return nil if !algorithm_record
  algorithm = algorithm_record['algorithm']
  eval algorithm
end

get '/:hwid' do |hwid|
  puts "***** request from device #{hwid}"
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

  puts "accept request from device #{hwid}"
  if settings.hwsockets[hwid]
    puts "close old connection #{hwid}"
    settings.hwsockets[hwid].close
  end

  if record['manual']
    if record['use-proxy']
      backend = ProxyBackend.new(ManualBackend.new(hwid, settings.swsockets), nil)
    else
      backend = ManualBackend.new hwid, settings.swsockets
    end
  else
    algorithm = settings.db[:algorithms].find(:'algorithm-id' => record['algorithm-id']).first
    if !algorithm
      puts "Device hasn't algorithm"
      return ''
    end
    algorithm = algorithm['algorithm']
    if algorithm.start_with?('#file:')
      algorithm = open(algorithm.gsub('#file:','').strip).read
    end
    backend = AlgorithmBackend.new algorithm
  end

  if !record['group'].nil? && !record['group'].empty?
    group_name = record['group']
    group = settings.groups[group_name]
    backend = GroupBackend.new backend, group
  end

  socket = DeviceWebSocket.new hwid, backend, settings.manual_hwsockets

  if !record['group'].nil? && !record['group'].empty?
    socket = attach_to_group(socket, record['group'])
  end

  return if !socket

  response = socket.start request

  if record['manual']
    settings.manual_hwsockets[hwid] = socket
  end
  settings.hwsockets[hwid] = socket
  response
end

set :manual_hwsockets, {}
set :hwsockets, {}
set :swsockets, {}
set :groups, {}
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'

Mongo::Logger.logger.level = ::Logger::FATAL
