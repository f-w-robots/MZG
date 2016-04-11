class DeviceManager
  def initialize
    @devices = {}
    @web_sockets = {}
  end

  def open_socket request
    request.websocket do |ws|
      @web_sockets[ws] = true

      ws.onopen do
        ws.send(manual_device_list)
      end

      ws.onmessage do |msg|
        ws.send(manual_device_list)
      end

      ws.onclose do
        ws.send({keys: []}.to_json)
      end
    end
  end

  def update_device
    @web_sockets.keys.each do |key|
      key.send(manual_device_list)
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

  private
  def manual_device_list
    {keys: @devices.map{|k,v|v.manual? && !v.group_interface? ? k : nil}.reject{|v|!v}}.to_json
  end
end
