# Simple arduino device simulator
#
# send detector states and accept commands by web-sockets
#
require 'byebug'

require 'digest/sha1'
require 'faye/websocket'

require './labirint'

SHA = Digest::SHA1.hexdigest ENV['ID'].to_s

def connect
  Thread::abort_on_exception = true
  Thread.new do
    EM.run {
      @ws = Faye::WebSocket::Client.new("ws://localhost:#{ENV['ASEVER_PORT'] || 2500}/#{SHA}")

      @ws.on :open do |event|
        p [:open]
      end

      @ws.on :message do |event|
        p [:message, event.data]
        event.data.each_char do |command|
          if command == 's'
            @stop = true
            @ws.close
          else
            @labirint.move command
          end
          @recived = true
        end
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
