class AlgorithmBackend
  def initialize algorithm
    @algorithm = algorithm
    @unread_messages = []
  end

  def on_open socket
    @thread = Thread.new do
      eval "#{@algorithm}"
    end
  end

  def on_message msg
    @unread_messages.push msg
  end

  def on_close
    @thread.terminate
  end

  def getSendMessagePermission!
    true
  end

  private
  def msg_empty?
    @unread_messages.empty?
  end

  def shift_msg
    @unread_messages.shift
  end
end
