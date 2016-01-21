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

def get_logic sha
  logic = settings.db[:logics].find({sha: sha}).first
  if logic
    logic[:logic]
  else
    ''
  end
end

# Evaluate logic from db
#
def next_step sha, msg
  eval "def logic(msg)
    #{get_logic(sha)}
  end"
  begin
    result = logic(msg)
  rescue Exception => e
    nil
  end
  result
end

get '/devices/list' do
  {keys: settings.sockets.keys}.to_json
end

get '/:sha' do |sha|
  if !request.websocket?
    ''
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets[sha] = ws
        puts "connected with id: #{sha}"
      end
      ws.onmessage do |msg|
        puts "message #{msg}"
        command = next_step(sha, msg)
        if command
          ws.send(command)
        else
          ws.close_websocket
        end
      end
      ws.onclose do
        puts "disconnected with id: #{sha}"
        settings.sockets.delete(sha)
      end
    end
  end
end

set :sockets, {}
set :port, ENV['ASERVER_PORT']
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :bind, '0.0.0.0'
