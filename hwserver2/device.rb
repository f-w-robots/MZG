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

  def start request
    request.websocket do |ws|
      @ws = ws

      ws.onopen do
        puts "connected with id: #{@hwid}"
        @backend.on_open(ws)
      end

      ws.onmessage do |msg|
        puts "message #{msg} from #{@hwid}"
        @backend.on_message(msg)
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        @backend.on_close
      end
    end
  end

  def message msg
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
