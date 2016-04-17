class Proxy < Brick
  def initialize hwid, driver
    @hwid = hwid
    @driver_class = driver::Main

    @messeges = []
  end

  def start
    @driver = @driver_class.new self

    @thread = Thread.new do
      loop do
        while @messeges.empty? || !@driver.finish?
          sleep 0.001
        end
        m = @messeges.shift
        puts "SHIFT msg #{m.inspect}"
        if @driver.finish?
          @driver.command m
        end
      end
    end
  end

  def in_msg_left msg, hwid
    @driver.message_from_device msg
  end

  def in_msg_right msg, hwid
    puts "MESSAGES to driver #{msg}"
    @messeges.push msg
    out_msg_right 'accepted'
  end

  def callback_left callback, hwid
    @callback_left = callback
  end

  def callback_right callback, hwid
    @callback_right = callback
  end

  def destroy

  end

  def out_msg_left msg
    @callback_left.in_msg_right(msg, @hwid)
  end

  def out_msg_right msg
    @callback_right.in_msg_left(msg, @hwid)
  end
end
