class Control < Brick
  def initialize hwid
    @hwid = hwid
  end

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
      end

      ws.onmessage do |msg|
        out_msg_left(msg)
      end

      ws.onclose do
      end
    end
  end

  def in_msg_left msg, hwid
    @ws.send(msg) if @ws
  end

  def destroy
    @ws.close_connection if @ws
  end

  private
  def out_msg_left msg
    @callback_left.in_msg_right(msg, @hwid)
  end

  def on_open socket
  end

  def on_close

  end
end
