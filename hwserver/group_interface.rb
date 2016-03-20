class GroupInterface
  def initialize on_open
    @on_open = on_open
    @interface_sockets = []
  end

  def start_interface request
    request.websocket do |ws|
      @interface_sockets.push(ws)

      ws.onopen do
        @on_open.call(ws)
      end

      ws.onmessage do |msg|
      end

      ws.onclose do
      end
    end
  end

  def send_message prefix, data
    @interface_sockets.each do |socket|
      socket.send({prefix: data}.to_json)
    end
  end

  def destroy
    @interface_sockets.each do |ws|
      ws.close_connection
    end
  end
end
