require 'socket'

STDOUT.sync = true
Thread::abort_on_exception = true

class Connection
  def initialize worker
    path_in = 'socket'
    @path_out = 'socket.server'
    File.unlink(path_in) if File.exists?(path_in)
    @server = UNIXServer.new(path_in)

    @worker = worker.new(self)

    Thread.new do
      loop do
        line = on_request
        @worker.from_device(line)
      end
    end
  end

  def send_allow?
    File.exists?(@path_out)
  end

  def to_device msg
    return false if !File.exists?(@path_out)
    socket = UNIXSocket.new(@path_out)
    socket.write(msg)
    socket.close
    true
  end

  private
  def on_request
    socket = @server.accept
    line = socket.readline
    socket.close
    line
  end
end
