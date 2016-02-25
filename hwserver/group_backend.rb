class GroupBackend
  def initialize backend, group
    @backend = backend
    @group = group
  end

  def on_open socket
    @backend.on_open socket
  end

  def on_message msg
    @backend.on_message msg
    hwid = @backend.instance_variable_get(:@hwid)
    @group.message_from_device hwid, msg
  end

  def on_close
    @backend.on_close
  end

  def getSendMessagePermission!
    true
  end
end
