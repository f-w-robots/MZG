# Server for devices
#
# Accepts connections from devices by web-sockets
# and control devices through the connections
#
require 'byebug'

require 'json'
require 'sinatra'
require 'sinatra-websocket'
require 'mongo'

class Control
  def initialize algorithm
    @algorithm = algorithm
    @unread_messages = []
  end

  def get_logic
    @algorithm
  end

  def push_msg msg
    @unread_messages.push msg
  end

  def msg_empty?
    @unread_messages.empty?
  end

  def shift_msg
    @unread_messages.shift
  end

  def socket_code socket
    eval "loop do
      #{@algorithm}
      sleep(0.001)
    end"
  end
end

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.hwsockets.reject{|k,v|!v[:manual]}.keys}.to_json
end

get '/control/:hwid' do |hwid|
  if !request.websocket?
    return ''
  end

  record = settings.db[:devices].find({hwid: hwid}).first
  if !record['manual']
    return ''
  end

  request.websocket do |ws|
    ws.onopen do
      settings.swsockets[hwid] = ws
    end
    ws.onmessage do |msg|
      hwsocket = settings.hwsockets[hwid]
      if hwsocket
        hwsocket[:socket].send(msg)
      end
    end
    ws.onclose do
      settings.swsockets.delete(hwid)
    end
  end
end

get '/:hwid' do |hwid|
  return '' if !request.websocket?

  record = settings.db[:devices].find({hwid: hwid}).first
  if !record['manual']
    device = Control.new record['algorithm']
  end

  request.websocket do |ws|
    ws.onopen do
      settings.hwsockets[hwid] = {manual: record['manual'], socket: ws}
      puts "connected with id: #{hwid}"
      if !record['manual']
        device.socket_code(ws)
      end
    end
    ws.onmessage do |msg|
      puts "message #{msg}"
      if !record['manual']
        device.push_msg msg
      else
        swsocket = settings.swsockets[hwid]
        if swsocket
          swsocket.send(msg)
        end
      end
    end
    ws.onclose do
      puts "disconnected with id: #{hwid}"
      settings.hwsockets.delete(hwid)
    end
  end
end

set :hwsockets, {}
set :swsockets, {}
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['ASERVER_PORT']
set :bind, '0.0.0.0'
