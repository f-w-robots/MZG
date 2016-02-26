class DeviceWebSocket
  def initialize hwid, backend, sockets
    @hwid = hwid
    @backend = backend
    @sockets = sockets

    @list = []

    @thread = Thread.new do
      loop do
        while !@ws
          sleep(0.1)
        end
        while(!@backend.getSendMessagePermission!)
          sleep(0.1)
        end
        while @list.size < 1
          sleep(0.1)
        end
        @ws.send(@list.shift)
      end
    end
  end

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
        puts "connected with id: #{@hwid}"
        @backend.on_open(ws)
      end
      ws.onmessage do |msg|
        puts "message #{msg} from #{@hwid}"
        @backend.on_message msg
      end
      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        destroy
        @backend.on_close
      end
    end
  end

  def on_message msg
    @list.push(msg)
  end

  def destroy
    @thread.terminate
    @sockets.delete @hwid
  end
end

class DeviceWebSocketForGroup
  def initialize socket, group, group_name
    @socket = socket
    @group = group
    @group_name = group_name
  end

  # method_missing
  def start request
    @socket.start request
  end

  def on_message msg
    hwid = @socket.instance_variable_get(:@hwid)
    @group.on_message hwid, msg
  end

  def direct_on_message msg
    @socket.on_message msg
  end

  def destroy
    @socket.destroy
  end
end
