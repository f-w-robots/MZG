# Simple arduino device simulator
#
# send detector states and accept commands by web-sockets
#
require 'byebug'

require 'digest/sha1'
require 'faye/websocket'
require 'yaml'

require './labirint'

CONFIG = YAML.load_file("config.yml")

def _init
  @sha = Digest::SHA1.hexdigest ENV['ID'].to_s
  port = CONFIG['aserver']['port']
  Thread.new do
    EM.run {
      @ws = ws = Faye::WebSocket::Client.new("ws://localhost:#{port}/#{@sha}")

      ws.on :open do |event|
        p [:open]
      end

      ws.on :message do |event|
        @labirint.move event.data
        p [:message, event.data]
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    }
  end
  @labirint = Labirint.new
end

def _loop
  return if !@ws
  @ws.send("#{@labirint.detector('f')}#{@labirint.detector('r')}-#{@labirint.detector('l')}")
end

_init
loop do
  _loop
  sleep 0.1
end
