class Device < Brick
  ABORT_TIMEOUT = 0.5

  def initialize hwid, manual
    @hwid = hwid
    @manual = manual
  end

  def hwid
    @hwid
  end

  def start request
    Thread.new do
      loop do
        sleep 0.001
        puts @send_to_device_time
        if @send_to_device_time && @send_to_device_time.to_f < (Time.now.to_f - ABORT_TIMEOUT)
          puts "ABORT!, retrive"
          @ws.send(@latest_message)
        end
      end
    end

    request.websocket do |ws|
      @ws = ws

      ws.onopen do
        puts "connected with id: #{@hwid}"
        on_open
      end

      ws.onmessage do |msg|
        @send_to_device_time = nil
        out_msg_right(msg)
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        on_close
      end
    end
  end

  def in_msg_right msg, hwid
    send_to_device msg
  end

  def destroy
    @ws.close_connection
  end

  def send_to_device msg
    puts "MSG to device: #{msg}"
    @send_to_device_time = Time.now
    @latest_message = msg
    @ws.send msg
  end

  private
  def out_msg_right msg
    puts "MSG from device: #{msg}"
    @callback_right.in_msg_left(msg, @hwid)
  end

  def on_open

  end

  def on_close

  end
end
