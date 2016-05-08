class Manager
  def initialize
    @devices = []
    @web_sockets = {}
    @mailer = Mailer.new
  end

  def connect device
    device = Device.new(device, self, @mailer)
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
      data = data.encode('UTF-8', {:invalid => :replace,:undef   => :replace,:replace => '?'})
      EM.next_tick { key.send({output: { hwid => [std, data] }}.to_json) }
    end
  end

  def manage ws
    ws.on(:open) do |event|
      puts "MANAGE open"
    end

    ws.on(:message) do |msg|
      puts "MANAGE: #{msg.data}"
      msg = JSON.parse(msg.data)

      if msg['list']
        EM.next_tick { ws.send(device_list) }
      end

      if msg['update']
        puts 'recreate_device'
        recreate_device(msg['update'])
      end
    end

    ws.on(:close) do |event|
      p [:close, event.code, event.reason]
      EM.next_tick { ws.send({devices: []}.to_json) }
      puts "MANAGE close"
    end

    ws.rack_response
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
      EM.next_tick { key.send(device_list) }
    end
  end

  private
  def device_list
    {devices: @devices.map{|d| d.record.hwid}}.to_json
  end
end
