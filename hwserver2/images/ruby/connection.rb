require 'socket'

STDOUT.sync = true
Thread::abort_on_exception = true

class UNIXConnection
  def initialize path_in, path_out, on_message
    @path_out = path_out
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
    socket = UNIXSocket.new(@path_out)
    socket.write(msg)
    socket.close
  end

  private
  def on_request
    socket = @server.accept
    line = socket.readline
    socket.close
    line
  end
end

class Connection
  def initialize worker = nil
    @device = UNIXConnection.new 'socket', 'socket.server', lambda {|msg| inbox_msg(msg)}
    @mail = UNIXConnection.new 'socket.mail', 'socket.mail.server', lambda {|msg| inbox_mail(msg)}

    @worker = worker.new(self) if worker
  end

  def to_device msg
    @device.send_message(msg)
  end

  def mail_to device, message
    @mail.send_message("#{device}#{30.chr}#{message}")
  end

  def mail_permission ids
    @mail.send_message("#{29.chr}#{ids.join(29.chr)}")
  end

  private
  def inbox_msg msg
    @worker.from_device(msg)
  end

  def inbox_mail mail
    from, message = mail.split(30.chr, 2)
    @worker.from_mail(from, message)
  end
end
