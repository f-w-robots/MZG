class Control
  def initialize device
    @device = device
  end

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
      end

      ws.onmessage do |msg|
        @device.message_to_device msg
      end

      ws.onclose do
      end
    end
  end

  def on_open socket
  end

  def on_message msg
    @ws.send msg
  end

  def on_close
    close
  end
end
