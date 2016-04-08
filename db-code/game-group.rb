# class Group
  def initialize record
    super
    @rounds = record.options[:rounds].to_i
    @timeout = record.options[:timeout].to_i
    @prepare_timeout = record.options[:prepare_timeout].to_i

    @options[:commands] = {}
    @options[:info] = {}
    @options[:info][:rounds_total] = @rounds
    @options[:info][:prepare] = true
    @options[:devices] = []

    @messages = {}
    @crashed = {}
    @finished = {}

    @devices_locked = []

    @clients = {}

    @commands = {}

    @interface = GroupInterface.new lambda { |ws|
      ws.send(avaliable_devices.to_json)

      @clients[ws] = {}

      Thread.new do
        loop do
          ws.send({info: @options[:info]}.to_json)
          sleep(1);
        end
      end
    }, lambda { |ws, msg|
      if msg["device"]
        return if @clients[ws][:device]
        @devices_locked.push msg["device"]
        ws.send(avaliable_devices.to_json)

        @clients[ws][:device] = msg["device"]

        if avaliable_devices[:devices].size < 1
          @prepare_timeout = 0
        end
      end

      if msg["commit"]
        if !@clients[ws][:device] || @commands[@clients[ws][:device]]
          return
        end

        @commands[@clients[ws][:device]] = msg["commit"]
        ws.send({commit: :lock}.to_json)
      end
    }
  end

  def avaliable_devices
    {devices: (@devices.keys - @devices_locked)}
  end

  def interface?
    true
  end

  def start_interface request
    @interface.start_interface request
  end

  def start
    @thread = Thread.new do
      while @options[:info][:prepare]
        @options[:info][:timeout] = @prepare_timeout
        sleep(1)
        @prepare_timeout -= 1
        if @prepare_timeout <= 0
          @options[:info][:prepare] = false
        end
      end
      for round in 1..@rounds
        @options[:info][:moving] = false
        @options[:info][:round] = round
        theend = Time.now + @timeout
        allow_accept

        loop do
          sleep 0.01
          @options[:info][:timeout] = theend - Time.now
          if theend < Time.now || @commands.keys.size == @devices_locked.size
            start_moving(round)
            break
          end
        end
      end
    end
  end

  def start_moving round
    @options[:info][:moving] = true
    allow_accept(false)
    @commands.each do |hwid, commands|
      @commands.delete hwid
      if @crashed[hwid]
        commands.unshift('restore')
        @crashed[hwid] = false
      end
      @finished[hwid] = false
      send_commands commands, hwid
    end

    # Wait responses
    loop do
      all_finish = true
      puts @finished

      @finished.keys.each do |hwid|
        if @messages[hwid] > 0
          all_finish = false
        end
      end

      if all_finish
        break
      end

      sleep 0.5
    end

    if round >= @rounds
      finish
      destroy
    end
  end

  def send_commands commands, hwid
    commands.each do |command|
      out_msg_left command, hwid
      @messages[hwid] ||= 0
      @messages[hwid] += 1
    end
  end

  def in_msg_left msg, hwid
    @options[:info][:score] ||= {}
    @options[:info][:score][hwid] ||= 0
    @options[:info][:score][hwid] += 1

    @options[:info][:waits] ||= {}
    @options[:info][:waits][hwid] ||= 0
    @options[:info][:waits][hwid] += 1

    clear_stack hwid, msg
    out_msg_right({response: msg}, hwid)
  end

  def in_msg_right msg, hwid
    if accept?
      @options[:commands][hwid] ||= []
      @options[:commands][hwid] << msg
    end
  end

  def out_msg_right msg, hwid
    _clients = {}
    @clients.each do |ws, hash|
      _clients[hash[:device]] = ws
    end
    if _clients[hwid]
      _clients[hwid].send(msg.to_json)
    end
  end

  def out_msg_right_all msg
    _clients = {}
    @clients.each do |ws, hash|
      ws.send(msg.to_json)
    end
  end

  def callback_left callback, hwid
    @devices[hwid] = callback
    @interface.send_message('devices', @devices.keys)
  end

  private
  def allow_accept yes = true
    @options[:info][:accept] = yes
    if yes
      out_msg_right_all({commit: :unlock})
    end
  end

  def accept?
    @options[:info][:accept]
  end

  def clear_stack hwid, msg
    if @messages[hwid]
      if msg == 'crash' || msg == 'win'
        @messages[hwid] = 0
        @crashed[hwid] = true
      elsif msg == 'ready'
        @messages[hwid] -= 1
      end
    end
  end

  def finish
    @options[:info][:finish] = true
    max = -1
    return if !@options[:info][:score]
    @options[:info][:score].each do |k,v|
      if v > max
        @options[:info][:winner] = k
        max = v
      end
    end
  end
# end
