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

    @responses = {}

    @interface = GroupInterface.new lambda { |ws|
      Thread.new do
        # TODO
        sleep(1)

        ws.send({devices: @devices.keys}.to_json)

        loop do
          ws.send({info: @options[:info]}.to_json)
          sleep(1);
        end
      end
    }
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
        @options[:info][:round] = round
        theend = Time.now + @timeout
        allow_accept
        loop do
          sleep 0.001
          @options[:info][:timeout] = theend - Time.now
          if theend < Time.now
            start_round(round)

            break
          end
        end
      end
    end
  end

  def start_round round
    allow_accept(false)
    @options[:commands].keys.each do |hwid|
      commands = @options[:commands][hwid]
      @options[:commands][hwid] = []
      if @crashed[hwid]
        commands.unshift('restore')
        @crashed[hwid] = false
      end
      @finished[hwid] = false
      @responses[hwid] = []
      @responses[hwid].push 'first'
      send_commands commands, hwid
    end

    # Wait responses
    loop do
      all_finish = true
      puts @finished

      @finished.keys.each do |hwid|
        if !@finished[hwid]
          all_finish = false
        end
      end
      puts all_finish
      if all_finish
        break
      end

      sleep 0.5
    end

    allow_accept

    if round >= @rounds
      finish
      destroy
    end
  end

  def send_commands commands, hwid
    thread = Thread.new do
      commands.each do |command|
        loop do
          sleep 0.1
          if @responses[hwid].size > 0
            if @responses[hwid].shift == 'crash'
              @finished[hwid] = true
              thread.terminate
            end
            break
          end
        end
        out_msg_left command, hwid
        @messages[hwid] ||= 0
        @messages[hwid] += 1
      end

      loop do
        sleep 0.1
        if @responses[hwid].size > 0
          break
        end

        @finished[hwid] = true
      end
    end
  end

  def in_msg_left msg, hwid
    @options[:info][:score] ||= {}
    @options[:info][:score][hwid] ||= 0
    @options[:info][:score][hwid] += 1

    @options[:info][:waits] ||= {}
    @options[:info][:waits][hwid] ||= 0
    @options[:info][:waits][hwid] += 1

    @responses[hwid].push msg

    clear_stack hwid, msg
    out_msg_right(msg, hwid)
  end

  def in_msg_right msg, hwid
    if accept?
      @options[:commands][hwid] ||= []
      @options[:commands][hwid] << msg
    end
  end

  def callback_left callback, hwid
    @devices[hwid] = callback
    @interface.send_message('devices', @devices.keys)
  end

  private
  def allow_accept yes = true
    @options[:info][:accept] = yes
  end

  def accept?
    @options[:info][:accept]
  end

  def clear_stack hwid, msg
    if @messages[hwid]
      if msg == 'crash' || msg == 'win'
        @messages[hwid] = 0
        @crashed[hwid] = true
      else
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
