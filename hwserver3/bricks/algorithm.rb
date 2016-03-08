class Algorithm < Brick
  def initialize hwid, algorithm
    @algorithm = algorithm
    @unread_messages = []
    @hwid = hwid
  end

  def start request
    @thread = Thread.new do
      eval @algorithm
    end
  end

  def in_msg_left msg, hwid
    @unread_messages.push msg
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
