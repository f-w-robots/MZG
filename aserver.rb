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
  {keys: settings.sockets.reject{|s|!s[:manual]}.keys}.to_json
end

get '/control/:hwid' do
  if !request.websocket?
    return ''
  end

  record = settings.db[:devices].find({hwid: hwid}).first
  if !record['manual']
    return ''
  end

  request.websocket do |ws|
    ws.onopen do
      settings.sockets[hwid] = ws
    end
    ws.onmessage do |msg|
      ws.send(msg)
    end
    ws.onclose do
      settings.sockets.delete(hwid)
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
      settings.sockets[hwid] = {manual: manual, socket: ws}
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

      end
    end
    ws.onclose do
      puts "disconnected with id: #{hwid}"
      settings.sockets.delete(hwid)
    end
  end
end

set :sockets, {}
set :port, ENV['ASERVER_PORT']
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :bind, '0.0.0.0'
set :algorithms, {}