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

class ControlBackend
  def initialize algorithm
    @algorithm = algorithm
    @unread_messages = []
  end

  def on_open socket
    eval "loop do
      #{@algorithm}
      sleep(0.001)
    end"
  end

  def on_message msg
    @unread_messages.push msg
  end

  def on_close
  end

  def getSendMessagePermission!
    true
  end

  private
  def msg_empty?
    @unread_messages.empty?
  end

  def shift_msg
    @unread_messages.shift
  end
end

class ManualBackend
  def initialize hwid, swsockets
    @hwid = hwid
    @swsockets = swsockets

    # TODO - protocol
    @init_message = false
    @waiting = false
    @wait = true
  end

  def on_open socket
    # swsocket = get_swsocket
    # swsocket.send('device connected') if swsocket
  end

  def on_message msg
    if(@waiting)
      if(msg == 'wait')
        @wait = true
      elsif(msg == 'crash')
        send_direct('crash')
      end
    elsif(!@init_message)
      @init_message = true
      if(msg == 'waiting')
        @waiting = true
      end
    else
      swsocket = get_swsocket
      swsocket.send(msg) if swsocket
    end
  end

  def on_close
    # swsocket = get_swsocket
    # swsocket.send('device disconnected') if swsocket
  end

  def getSendMessagePermission!
    if @waiting
      if @wait
        @wait = false
        send_direct('executed')
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def send_direct msg
    swsocket = get_swsocket
    swsocket.send(msg.to_s) if swsocket
  end

  private
  def get_swsocket
    @swsockets[@hwid]
  end
end

class DeviceWebSocket
  def initialize hwid, backend
    @hwid = hwid
    @backend = backend

    @list = []

    Thread.new do
      loop do
        while !@ws
          sleep(0.1)
        end
        while(!@backend.getSendMessagePermission!)
          sleep(0.1)
        end
        while @list.size < 1
          sleep(0.1)
        end
        @ws.send(@list.shift)
      end
    end
  end

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
        puts "connected with id: #{@hwid}"
        @backend.on_open(ws)
      end
      ws.onmessage do |msg|
        puts "message #{msg}"
        @backend.on_message msg
      end
      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        @backend.on_close
      end
    end
  end

  def on_message msg
    @list.push(msg)
  end
end

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.manual_hwsockets.keys}.to_json
end

get '/control/:hwid' do |hwid|
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

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

get '/:hwid' do |hwid|
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

  if record['manual']
    backend = ManualBackend.new hwid, settings.swsockets
  else
    backend = ControlBackend.new settings.db[:algorithms]
      .find(:'algorithm-id' => record['algorithm-id']).first['algorithm']
  end

  socket = DeviceWebSocket.new hwid, backend
  response = socket.start request

  if record['manual']
    settings.manual_hwsockets[hwid] = socket
  end
  response
end

set :manual_hwsockets, {}
set :swsockets, {}
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'
