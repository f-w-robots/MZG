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
        @send_to_device_time = nil
        out_msg_right(msg)
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        on_close
      end
    end
  end

  def start_abort_control abort_timeout
    Thread.new do
      loop do
        sleep 0.001
        if @send_to_device_time && @send_to_device_time.to_f < (Time.now.to_f - abort_timeout)
          puts "ABORT!, retrive"
          @send_to_device_time = Time.now
          send_to_device(@latest_message)
        end
      end
    end
  end

  def in_msg_right msg, hwid
    if msg.start_with?('MAX_TIMEOUT:')
      start_abort_control(msg.sub('MAX_TIMEOUT:', '').to_f)
      return
    end
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
