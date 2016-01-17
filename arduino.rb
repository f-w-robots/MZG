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
SHA = Digest::SHA1.hexdigest ENV['ID'].to_s

def connect
  Thread.new do
    EM.run {
      @ws = Faye::WebSocket::Client.new("ws://localhost:#{CONFIG['aserver']['port']}/#{SHA}")

      @ws.on :open do |event|
        p [:open]
      end

      @ws.on :message do |event|
        event.data.each_char do |command|
          if command == 's'
            @stop = true
            @ws.close
          else
            @labirint.move command
          end
          @recived = true
        end
        p [:message, event.data]
      end

      @ws.on :close do |event|
        p [:close, event.code, event.reason]
        @ws = nil
      end
    }
  end
end

def _init
  @labirint = Labirint.new
  @recived = true
end

def _loop
  return if @stop || !@recived
  if !@ws
    connect
  else
    @recived = false
    sensors = @labirint.sensors.map{|e|e ? e : '-'}
    @ws.send("#{sensors[0]}#{sensors[1]}#{sensors[2]}#{sensors[3]}")
  end
end

_init
loop do
  _loop
  sleep 0.0001
end
