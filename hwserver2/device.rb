class Device
  def initialize hwid, record
    @hwid = hwid
    @manual = record.manual?

    if record.manual?
      @backend = ControlBackend.new self
    else
      @backend = AlgorithmBackend.new record.algorithm
    end
  end

  def hwid
    @hwid
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
        message_from_device(msg)
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        on_close
      end
    end
  end

  def on_open
    @backend.on_open(@ws)
  end

  def message_from_device msg
    @backend.on_message(msg)
  end

  def on_close
    @backend.on_close
  end

  def message_to_device msg
    @ws.send(msg)
  end

  def close
    @ws.close_connection
  end

  def manual?
    @manual
  end

  def backend
    @backend
  end
end
