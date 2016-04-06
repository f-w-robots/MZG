# Work with sensors data
#
# module LineFollower
  class Sensors
    OneZeroDeliver = 5
    MaxHistory = 10

    def initialize
      @history = []
    end

    def update values, print = false
      @history.unshift(values)
      @history = @history[0..(MaxHistory-1)]
      if print
        puts "last: #{values[0..4]}"
        puts "medium: #{medium(0)}#{medium(1)}#{medium(2)}#{medium(3)}#{medium(4)}"
      end
    end

    def value s
      if s == 'l' || s == 'r'
        if sensorRaw(s) <= OneZeroDeliver && sensorRaw(s) > OneZeroDeliver - 2
          if (sensorRaw(s == 'l' ? 'r' : 'l' ) - sensorRaw(s)).abs > 3
            return true
          else
            return false
          end
        end
      end
      sensorRaw(s) <= OneZeroDeliver
    end

    private
    def sensorRaw s
      if s == 'rr'
        medium(4)
      elsif s == 'll'
        medium(0)
      elsif s == 'r'
        medium(3)
      elsif s == 'l'
        medium(1)
      elsif s == 'c'
        medium(2)
      end
    end

    def medium sensor_number
      result = 0
      @history.each do |row|
        result += row[sensor_number].to_i
      end
      (result / @history.size).round
    end
  end

  # Create answer - command for car
  #
  class Answer
    def initialize
      @answer = []
    end

    def stop
      puts '*** stop'
      @answer.push '18!0"0#0$0'
    end

    def start
      puts '*** start'
      @answer.push '18!0"1#1$0'
    end

    def right
      puts '*** right'
      @answer.push '18!1"0#1$0'
    end

    def left
      puts '*** left'
      @answer.push '18!0"1#0$1'
    end

    def right_wheel
      puts '*** right_wheel'
      @answer.push '18!0"1#0$0'
    end

    def left_wheel
      puts '*** left_wheel'
      @answer.push '18!0"0#1$0'
    end

    def get
      if @answer.size != 1
        raise("end loop, @answers count #{@answer.size}")
      else
        @answer.shift
      end
    end
  end

  class Mover
    TURN_SENSORS = {'right' => 'rr', 'left' => 'll'}

    def initialize sensor, answer, commands
      @sensor = sensor
      @answer = answer
      @commands = commands
    end

    def sensor value
      @sensor.value value
    end

    def move command
      puts "allow_time: #{allow_time}" if @time
      puts "#{command}, step_mode: #{@step_mode}"
      send(command)
      puts '-'*12
    end

    private
    def allow_time
      if !@time[:start]
        true
      else
        Time.now.to_f - @time[:start].to_f > @time[:delta]
      end
    end

    def forward
      if @time && @time[:delay] && @time[:start]
        @time[:start] += (Time.now.to_f - @time[:delay])
        @time.delete :delay
      end
      if !@step_mode
        if (sensor('rr') || sensor('ll'))
          @step_mode = {step: -1}
          @time = {start: Time.now, delta: 2}
        else
          @time = {}
          @step_mode = {step: 0}
        end
      end

      case @step_mode[:step]
      when -1
        if !sensor('rr') && !sensor('ll')
          @step_mode[:step] = 0
        end
        if sensor('r') && !(sensor('r') && sensor('l'))
          @answer.right
          @time[:delay] = Time.now.to_f
          return
        end
        if sensor('l') && !(sensor('r') && sensor('l'))
          @answer.left
          @time[:delay] = Time.now.to_f
          return
        end
        @answer.start
      when 0
        if (sensor('rr') || sensor('ll')) && allow_time
          @step_mode = {step: 1, sensor: (sensor('ll') ? 'll' : 'rr')}
        end
        if sensor('r') && !(sensor('r') && sensor('l'))
          @answer.right
          @time[:delay] = Time.now.to_f
          return
        end
        if sensor('l') && !(sensor('r') && sensor('l'))
          @answer.left
          @time[:delay] = Time.now.to_f
          return
        end
        @answer.start
      when 1
        case @step_mode[:sensor]
        when 'rr'
          if sensor('ll')
            finish_command
          else
            @answer.left_wheel
          end
        when 'll'
          if sensor('rr')
            finish_command
          else
            @answer.right_wheel
          end
        end
      end
    end

    def left
      turn 'left'
    end

    def right
      turn 'right'
    end

    def turn direction
      if !@step_mode
        if sensor(TURN_SENSORS[direction])
          @step_mode = -1
        else
          @step_mode = 0
        end
      end
      case @step_mode
      when 1
        if !sensor(TURN_SENSORS[direction])
          finish_command
        else
          @answer.send(direction)
        end
      when 0
        if sensor(TURN_SENSORS[direction])
          @step_mode = 1
        end
        @answer.send(direction)
      when -1
        if !sensor(TURN_SENSORS[direction])
          @step_mode = 0
        end
        @answer.send(direction)
      end
    end

    def stop
      finish_command
    end

    def search
      if @step_mode && @step_mode[:step] == 1
        if !sensor('l') && @step_mode[:turn] == :left
          finish_command
        elsif !sensor('r') && @step_mode[:turn] == :right
          finish_command
        else
          @answer.send(@step_mode[:turn])
        end
        return
      elsif sensor('c')
        if sensor('l')
          @step_mode = {step: 1, turn: :left}
        else
          @step_mode = {step: 1, turn: :right}
        end
      end
      @answer.start
    end

    def finish_command
      @step_mode = nil
      @time = nil
      @answer.stop
      @commands.finish

      puts "FINISH #{'-'*150}"
      puts "#{'#'*160}"
      puts "#{'#'*160}"
    end
  end

  class Main
    def initialize device
      @device = device

      @answer = Answer.new
      @sensors = Sensors.new
      @mover = Mover.new @sensors, @answer, self

      @device.out_msg_left('04INIT')
      @device.out_msg_left('18!0"0#0$0')

      @messages = []

    end

    # def stop_command!
    #   @device.out_msg_left('18!0"0#0$0')
    # end

    def finish
      @command = nil
      @device.out_msg_right 'ready'
    end

    def finish?
      !@command
    end

    def command cmd
      @command = cmd

      @thread = Thread.new do
        loop do
          wait_message

          @sensors.update shift_msg, true

          @mover.move current_command

          @device.out_msg_left(@answer.get)

          if finish?
            break
          end
        end
      end
    end

    def current_command
      @command
    end

    def message_from_device msg
      @messages.push msg
    end

    private
    def wait_message
      while msg_empty?
        sleep 0.000001
      end
    end

    def msg_empty?
      @messages.empty?
    end

    def shift_msg
      @messages.shift
    end
  end
# end
