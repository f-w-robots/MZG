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
        out_msg(msg)
      end

      ws.onclose do
      end
    end
  end

  def in_msg msg, hwid
    @ws.send(msg) if @ws
  end

  private
  def out_msg msg
    @callback.in_msg(msg, @hwid)
  end

  def on_open socket
  end

  def on_close

  end

  def destroy
    @ws.close_connection
  end
end
