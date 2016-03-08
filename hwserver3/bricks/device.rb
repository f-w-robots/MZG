class Device < Brick
  def initialize hwid, manual
    @hwid = hwid
    @manual = manual
  end

  def hwid
    @hwid
  end

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
        puts "connected with id: #{@hwid}"
        on_open
      end

      ws.onmessage do |msg|
        puts "message #{msg} from #{@hwid}"
        out_msg(msg)
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        on_close
      end
    end
  end

  def in_msg msg, hwid
    @ws.send(msg)
  end

  def destroy
    @ws.close_connection
  end

  def manual?
    @manual
  end

  def manual
    @manual
  end

  private
  def out_msg msg
    @callback.in_msg(msg, @hwid)
  end

  def on_open

  end

  def on_close

  end
end
