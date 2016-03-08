class Group < Brick
  def initialize record
    @options = {}

    @devices = {}
    @interfaces = {}
  end

  def callback_left callback, hwid
    @devices[hwid] = callback
  end

  def callback_right callback, hwid
    @interfaces[hwid] = callback
  end

  def out_msg_left msg, hwid
    @devices[hwid].in_msg_right(msg, hwid)
  end

  def out_msg_right msg, hwid
    @interfaces[hwid].in_msg_left(msg, hwid)
  end

  def destroy
    @thread.terminate
  end

  def options
    @options
  end
end
