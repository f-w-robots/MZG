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

def get_logic hwid
  settings.algorithms[hwid]
end

# Evaluate logic from db
#
def next_step hwid, msg
  eval "def logic(msg)
    #{get_logic(hwid)}
  end"
  begin
    result = logic(msg)
  rescue Exception => e
    nil
  end
  result
end

get '/devices/list/manual' do
  {keys: settings.hwsockets.reject{|s|!s[:manual]}.keys}.to_json
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
  if !request.websocket?
    return ''
  end

  record = settings.db[:devices].find({hwid: hwid}).first
  manual = record['manual']
  if !manual
    settings.algorithms[hwid] = record['algorithm']
  else

  end

  request.websocket do |ws|
    ws.onopen do
      settings.hwsockets[hwid] = {manual: manual, socket: ws}
      puts "connected with id: #{hwid}"
    end
    ws.onmessage do |msg|
      puts "message #{msg}"
      if !manual
        command = next_step(hwid, msg)
        if command
          ws.send(command)
        else
          ws.close_websocket
        end
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
set :port, ENV['ASERVER_PORT']
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :bind, '0.0.0.0'
set :algorithms, {}
