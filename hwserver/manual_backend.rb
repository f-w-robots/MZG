class ManualBackend
  def initialize hwid, swsockets
    @hwid = hwid
    @swsockets = swsockets

    @init_message = false
    @waiting = false
  end

  def on_open socket

  end

  def on_message msg
    init_protocol(msg)
    if(@waiting)
      if(msg == 'wait')
        @wait = true
      elsif(msg == 'crash')
        send_direct('crash')
      end
    else
      swsocket = get_swsocket
      swsocket.send(msg) if swsocket
    end
  end

  def on_close

  end

  def getSendMessagePermission!
    if @waiting
      if @wait
        @wait = false
        send_direct('executed')
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def send_direct msg
    swsocket = get_swsocket
    swsocket.send(msg.to_s) if swsocket
  end

  private
  def get_swsocket
    @swsockets[@hwid]
  end

  def init_protocol msg
    return if @init_message
    @init_message = true
    @wait = true
    if(msg == 'waiting')
      @waiting = true
    end
  end
end
