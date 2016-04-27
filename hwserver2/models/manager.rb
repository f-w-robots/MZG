class Manager
  def initialize
    @devices = []
    @web_sockets = {}
  end

  def connect device
    device = Device.new(device, self)
    response = device.start
    @devices.push device
    on_device_connected

    response
  end

  def disconnected device
    @devices.delete device
    on_device_disconnected
  end

  def on_device_connected
    update_devices_list
  end

  def on_device_disconnected
    update_devices_list
  end

  def new_output hwid, std, data
    @web_sockets.keys.each do |key|
      key.send({output: { hwid => [std, data] }}.to_json)
    end
  end

  def manage request
    request.websocket do |ws|
      @web_sockets[ws] = true

      ws.onopen do

      end

      ws.onmessage do |msg|
        puts "MANAGE: #{msg}"
        msg = JSON.parse(msg)

        if msg['list']
          ws.send(device_list)
        end

        if msg['update']
          puts 'recreate_device'
          recreate_device(msg['update'])
        end
      end

      ws.onclose do
        ws.send({devices: []}.to_json)
      end
    end
  end

  def recreate_device hwid
    puts "recreate_device: #{hwid}"
    device = device_by_hwid(hwid)
    device.recreate_container if device
  end

  def device_by_hwid hwid
    @devices.select{|d| d.record.hwid == hwid}.first
  end

  def update_devices_list
    @web_sockets.keys.each do |key|
      key.send(device_list)
    end
  end

  private
  def device_list
    {devices: @devices.map{|d| d.record.hwid}}.to_json
  end
end
