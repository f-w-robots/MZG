require 'byebug'

require 'sinatra'
require 'sinatra-websocket'

LOGIC = {
  '356a192b7913b04c54574d18c28d46e6395428ab' => "'left'",
  'da4b9237bacccdf19c0760cab7aec4a8359010b0' => "'right'",
}

def next_step sha, msg
  eval "def logic(msg)
    #{LOGIC[sha]}
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
        warn("websocket closed")
        settings.sockets.delete(sha)
      end
    end
  end
end

set :sockets, {}
set :port, 2500
