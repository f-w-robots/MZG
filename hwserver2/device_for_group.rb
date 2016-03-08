class DeviceForGroup < Device
  def initialize hwid, record, group
    device = super(hwid, record)
    @group = group
    @group.add(self)
  end

  def start request
    request.websocket do |ws|
      @ws = ws
      ws.onopen do
        puts "connected with id: #{@hwid}"
        on_open
      end

      ws.onmessage do |msg|
        puts "message #{msg} from #{@hwid}"
        on_message(msg)
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        on_close
      end
    end
  end

  def on_message msg
    puts "message from device #{@hwid}: #{msg}"
    @group.message_from_device @hwid, msg
  end

  def message msg
    puts "message from backend #{@hwid}: #{msg}"
    @group.message_from_backend @hwid, msg
  end
end
