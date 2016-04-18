require 'faye/websocket'
Thread::abort_on_exception = true

EM.run {
  @ws = Faye::WebSocket::Client.new("ws://0.0.0.0:2500/bugDebug")

  @ws.on :open do |event|
    p [:open]
  end

  @ws.on :message do |event|
    next if event.data == '04INIT'
    msg = "#{rand(10)}#{rand(10)}#{rand(10)}#{rand(10)}#{rand(10)}"
    puts "#{event.data} #{msg}"
    @ws.send(msg)
  end

  @ws.on :close do |event|
    @ws = nil
  end
}
