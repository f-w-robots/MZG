require 'socket'

class UNIXConnection
  def initialize on_message
    path_in = 'socket'
    @path_out = 'socket.server'
    File.unlink(path_in) if File.exists?(path_in)
    @server = UNIXServer.new(path_in)
    Thread.new do
      loop do
        line = on_request
        on_message.call(line)
      end
    end
  end

  def send_allow?
    File.exists?(@path_out)
  end

  def send_message msg
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
