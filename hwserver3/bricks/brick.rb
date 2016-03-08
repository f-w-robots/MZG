class Brick
  def initialize
    raise('abstract')
  end

  def start request
    raise('abstract')
  end

  def callback_right callback, hwid
    @callback_right = callback
  end

  def callback_left callback, hwid
    @callback_left = callback
  end

  def in_msg_left msg, hwid
    raise('abstract')
  end

  def in_msg_right msg, hwid
    raise('abstract')
  end

  private
  def out_msg_right msg
    raise('abstract')
  end

  def out_msg_left msg
    raise('abstract')
  end

  def on_open
    raise('abstract')
  end

  def on_close
    raise('abstract')
  end

  def destroy
    raise('abstract')
  end
end
