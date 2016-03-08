require_relative 'i2c_proxy.rb'

class DeviceProxy
  def initialize device, device_record
    @device = device
    @proxy = LineFollower::Main.new @device, self
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

  # Message from Device
  def message_from_device msg
    puts "message from device #{@hwid}: #{msg}"
    @proxy.message_from_device msg
  end

  # Message to device
  def message_to_device msg
    puts "message from backend #{@hwid}: #{msg}"
    @proxy.command msg
  end

  def hwid
    @hwid
  end

  def on_open

  end

  def on_close

  end

  def close

  end

  def manual?
    @device.manual?
  end

  def backend
    @backend
  end

  def backend= backend
    @backend = backend
  end
end
