# class Group
  def initialize record
    super
    @rounds = record.options[:rounds].to_i
    @timeout = record.options[:timeout].to_i

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
                out_msg_left 'Srestore', key
              end
              @options[:commands][key].each do |command|
                out_msg_left command, key
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
              sleep 0.1
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

  def in_msg_left msg, hwid
    @options[:info][:score] ||= {}
    @options[:info][:score][hwid] ||= 0
    @options[:info][:score][hwid] += 1
    clear_stack hwid, msg
    out_msg_right(msg, hwid)
  end

  def in_msg_right msg, hwid
    if accept?
      @options[:commands][hwid] ||= []
      @options[:commands][hwid] << msg
    end
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
