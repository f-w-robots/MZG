require 'byebug'

require 'digest/sha1'
require 'faye/websocket'

def _init
  @sha = Digest::SHA1.hexdigest ENV['ID'].to_s
  port = 2500
  Thread.new do
    EM.run {
      @ws = ws = Faye::WebSocket::Client.new("ws://localhost:#{port}/#{@sha}")

      ws.on :open do |event|
        p [:open]
      end

      ws.on :message do |event|
        p [:message, event.data]
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    }
  end
end

def _loop
  return if !@ws
  @ws.send("r#{rand(2)}l#{rand(2)}d#{rand(2)}")
end

_init
loop do
  _loop
  sleep 1
end
