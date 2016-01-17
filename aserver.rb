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

CONFIG = YAML.load_file("config.yml")

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
# Example:
# if msg[:left] == 2
#   'ls'
# elsif msg[:forward] == 2
#   'fs'
# elsif msg[:right] == 2
#   'rs'
# else
#   if msg[:left] == 0
#     'l'
#   elsif msg[:forward] == 0
#     'f'
#   elsif msg[:right] == 0
#     'r'
#   else
#     'b'
#   end
# end
def next_step sha, msg
  eval "def logic(msg)
    #{get_logic(sha)}
  end"
  logic({forward: msg[0].to_i, right: msg[1].to_i, left: msg[3].to_i})
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
        puts msg
        a = next_step(sha, msg)
        ws.send(a)
      end
      ws.onclose do
        puts "disconnected with id: #{sha}"
        settings.sockets.delete(sha)
      end
    end
  end
end

set :sockets, {}
set :port, CONFIG['aserver']['port']
set :db, Mongo::Client.new([ "#{CONFIG['database']['host']}:#{CONFIG['database']['port']}" ],
  :database => CONFIG['database']['dbname'])
