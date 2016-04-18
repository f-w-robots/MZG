class Algorithm < Brick
  def initialize hwid, algorithm, bricks
    @algorithm = algorithm
    @unread_messages = []
    @hwid = hwid
    @bricks = bricks
  end

  def start request
    run_code @algorithm
  end

  def restart algorithm
    @thread.terminate
    run_code algorithm
  end

  def run_code code
      @thread = Thread.new do
        begin
          eval code
        rescue
          @bricks.bad_code
        end
      end
  end

  def in_msg_left msg, hwid
    @unread_messages.push msg
    if (defined? self.on_message)
      self.on_message(msg)
    end
  end

  def destroy
    @thread.terminate
  end

  private
  def out_msg_left msg
    @callback_left.in_msg_right(msg, @hwid)
  end

  def on_open

  end

  def on_close

  end

  def msg_empty?
    @unread_messages.empty?
  end

  def shift_msg
    @unread_messages.shift
  end
end
