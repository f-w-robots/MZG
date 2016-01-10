require 'byebug'

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

def next_step sha, msg
  eval "def logic(msg)
    #{get_logic(sha)}
  end"
  logic(msg)
end

get '/:sha' do |sha|
  if !request.websocket?
    ''
  else
    request.websocket do |ws|
      ws.onopen do
        ws.send("OK")
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
set :port, 2500
set :db, Mongo::Client.new([ 'localhost:28001' ], :database => 'mzg')
