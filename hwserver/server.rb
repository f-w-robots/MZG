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
    eval "#{@algorithm}"
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

    @init_message = false
    @waiting = false
  end

  def on_open socket

  end

  def on_message msg
    init_protocol(msg)
    if(@waiting)
      if(msg == 'wait')
        @wait = true
      elsif(msg == 'crash')
        send_direct('crash')
      end
    else
      swsocket = get_swsocket
      swsocket.send(msg) if swsocket
    end
  end

  def on_close

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

  def init_protocol msg
    return if @init_message
    @init_message = true
    @wait = true
    if(msg == 'waiting')
      @waiting = true
    end
  end
end

class DeviceWebSocket
  def initialize hwid, backend, sockets
    @hwid = hwid
    @backend = backend
    @sockets = sockets

    @list = []

    @thread = Thread.new do
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
        destroy
        @backend.on_close
      end
    end
  end

  def on_message msg
    @list.push(msg)
  end

  def destroy
    @thread.terminate
    @sockets.delete @hwid
  end
end

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.manual_hwsockets.keys}.to_json
end

get '/group/info/:name' do |name|
  group = settings.groups[name]
  if !group
    status 404
    return
  end
  group[:info].to_s
end

post '/group/up/:name' do |name|
  record = settings.db[:games].find(name: name).first
  settings.groups[name] = {record: record, list: [], info: {}}
  group = settings.groups[name]
  code = record[:code]

  thread = Thread.new do
    theend = Time.now + 90
    loop do
      sleep 1
      group[:info][:timout] = theend - Time.now
      if theend < Time.now
        puts "MSGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
        puts group[:list]
        puts "-"*30
      end
    end
  end

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

  if group
    request.websocket do |ws|
      ws.onopen do
        settings.swsockets[hwid] = ws
      end
      ws.onmessage do |msg|
        hwsocket = settings.manual_hwsockets[hwid]
        return if !hwsocket
        group[:list].push(msg);
      end
      ws.onclose do
        settings.swsockets.delete(hwid)
      end
    end
  else
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
end

get '/:hwid' do |hwid|
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

  if !record['group'].nil? && !record['group'].empty?
    group = settings.db[:games].find(name: record['group']).first
  end

  if record['manual']
    backend = ManualBackend.new hwid, settings.swsockets
  else
    algorithm = ControlBackend.new settings.db[:algorithms]
      .find(:'algorithm-id' => record['algorithm-id']).first
    if !algorithm
      puts "Device hasn't algorithm"
      return ''
    end
    backend = ControlBackend.new algorithm['algorithm']
  end

  socket = DeviceWebSocket.new hwid, backend, settings.manual_hwsockets
  response = socket.start request

  if record['manual']
    settings.manual_hwsockets[hwid] = socket
  end
  response
end

set :manual_hwsockets, {}
set :swsockets, {}
set :game_tmp, {}
set :groups, {}
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'
