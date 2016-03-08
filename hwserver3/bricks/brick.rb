class Brick
  def initialize
    raise('abstract')
  end

  def start request
    raise('abstract')
  end

  def callback callback, hwid
    @callback = callback
  end

  def in_msg msg, hwid
    raise('abstract')
  end

  private
  def out_msg msg
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
