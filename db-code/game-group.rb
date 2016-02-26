# class Group
  def initialize hwsockets, record
    @hwsockets = hwsockets
    @record = record

    @rounds = record[:options][:rounds].to_i
    @timeout = record[:options][:timeoutM].to_i * 60 + record[:options][:timeoutS].to_i

    @options = {}
    @options[:commands] = {}
    @options[:info] = {}

    @messages = {}

    @crashed = {}
  end

  def start
    @thread = Thread.new do
      for round in 1..@rounds
        theend = Time.now + @timeout
        allow_accept
        loop do
          sleep 0.001
          @options[:info][:timout] = theend - Time.now
          if theend < Time.now
            allow_accept(false)
            @options[:commands].keys.each do |key|
              if @crashed[key]
                @crashed[key] = false
                @hwsockets[key].direct_on_message 'Srestore'
              end
              @options[:commands][key].each do |command|
                @hwsockets[key].direct_on_message command
                @messages[key] ||= 0
                @messages[key] += 1
              end
              @options[:commands][key] = []
            end

            # Wait responses
            while true
              puts @messages
              count = 0
              @messages.each do |k, v|
                count += v
              end
              break if count <= 0
              sleep 1
            end

            allow_accept

            if round >= @rounds
              finish
              destroy
            end

            break
          end
        end
      end
    end
  end

  def allow_accept yes = true
    @options[:info][:accept] = yes
  end

  def accept?
    @options[:info][:accept]
  end

  def on_message hwid, msg
    puts 'income ' + hwid
    if accept?
      puts 'accept ' + hwid
      @options[:commands][hwid] ||= []
      @options[:commands][hwid] << msg
    end
  end

  def destroy
    @thread.terminate
  end

  def options
    @options
  end

  def message_from_device hwid, msg
    @options[:info][:score] ||= {}
    @options[:info][:score][hwid] ||= 0
    @options[:info][:score][hwid] += 1
    clear_stack hwid, msg
  end

  private
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
    max = -1
    @options[:info][:score].each do |k,v|
      if v > max
        @options[:info][:winner] = k
        max = v
      end
    end
  end
# end
