class DeviceManager
  def initialize
    @devices = {}
    @web_sockets = {}
  end

  def open_socket request
    request.websocket do |ws|
      @web_sockets[ws] = true

      ws.onopen do

      end

      ws.onmessage do |msg|
        if msg == 'devices'
          ws.send(device_list)
        elsif msg.start_with?('kill_device:')
          @devices[msg.sub('kill_device:', '')].destroy if @devices[msg.sub('kill_device:', '')]
        else
          msg = JSON.parse(msg)
          if msg["restart"]
            hwid = msg["restart"]
            code = msg["code"].sub('\n', "\n")
            @devices[hwid].restart code
          end
        end
      end

      ws.onclose do
        ws.send({devices: {manual: [], algorithm: []}}.to_json)
      end
    end
  end

  def update_device
    @web_sockets.keys.each do |key|
      key.send(device_list)
    end
  end

  def device_destroy hwid
    @devices.delete hwid
    update_device
  end

  def device hwid
    @devices[hwid]
  end

  def device_add hwid, device
    @devices[hwid] = device
    update_device
  end

  def bad_code hwid
    @web_sockets.keys.each do |key|
      key.send({bad_code: :hwid}.to_json)
    end
  end

  private
  def device_list
    devices = @devices.map{|k,v|!v.group_interface? ? v : nil}.reject{|v|!v}
    {
      devices: devices.map{|d| d.hwid}
    }.to_json
  end
end
