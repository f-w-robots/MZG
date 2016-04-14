class Device < Brick
  def initialize hwid, bricks
    @hwid = hwid
    @bricks = bricks

    @threads = {}
    @log = Logger.new(hwid)
  end

  def hwid
    @hwid
  end

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
        @log.write "connected with id: #{@hwid}"
        if ws.pingable?
          start_ping_thread 5, 3
          @log.write "PING-PONG supported"
        else
          @log.write "PING-PONG not supported"
        end
        on_open
      end

      ws.onmessage do |msg|
        @send_to_device_time = nil
        out_msg_right(msg)
      end

      ws.onclose do
        @log.write "disconnected with id: #{@hwid}"
        on_close
      end

      ws.onpong do
        @wait_pong = false
        @log.write "RECIVE PONG"
      end
    end
  end

  def start_ping_thread time, timeout
    @threads[:ping] = Thread.new do
      loop do
        sleep 5
        if @wait_pong
          @log.write "ABORTED by PING-PONG"
          on_close
          break
        end
        @ws.ping(body = '')
        @wait_pong = true
      end
    end
  end

  def in_msg_right msg, hwid
    send_to_device msg
  end

  def destroy
    @ws.close_connection
    @threads.each do |key, thread|
      thread.terminate
    end
  end

  def send_to_device msg
    @log.write "MSG to device: #{msg}"
    @send_to_device_time = Time.now
    @latest_message = msg
    @ws.send msg
  end

  private
  def out_msg_right msg
    @log.write "MSG from device: #{msg}"
    @callback_right.in_msg_left(msg, @hwid)
  end

  def on_open

  end

  def on_close
    @bricks.destroy
  end
end
