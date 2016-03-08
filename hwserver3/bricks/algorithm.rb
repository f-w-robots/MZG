class Algorithm < Brick
  def initialize hwid, algorithm
    @algorithm = algorithm
    @unread_messages = []
    @hwid = hwid
  end

  def start request
    @thread = Thread.new do
      puts 'empty0'
      eval @algorithm
    end
  end

  def in_msg msg, hwid
    @unread_messages.push msg
  end

  def destroy
    @thread.terminate
  end

  private
  def out_msg msg
    @callback.in_msg(msg)
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
