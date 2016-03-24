# Work with sensors data
#
# module LineFollower
  class Sensors
    OneZeroDeliver = 5

    def update values, print = false
      @values = values
      if print
        puts @values[0..4]
        puts '-'*10
      end
    end

    def value s
      sensorRaw(s) <= OneZeroDeliver
    end

    # 'r', 'l', 'rr', 'll', 'c', 'f'
    def sensorRaw s
      (if s == 'rr'
        @values[4]
      elsif s == 'll'
        @values[0]
      elsif s == 'r'
        @values[3]
      elsif s == 'l'
        @values[1]
      elsif s == 'c'
        @values[2]
      end).to_i
    end
  end

  # Create answer - command for car
  #
  class Answer
    def initialize
      @answer = []
    end

    def stop
      @answer.push '18!0"0#0$0'
    end

    def start
      @answer.push '18!1"0#0$1'
    end

    def right
      @answer.push '18!0"1#0$1'
    end

    def left
      @answer.push '18!1"0#1$0'
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
      if(@skip_timeout)
        @skip_timeout -= 1
        @skip_timeout_action.call
        @skip_timeout = nil if @skip_timeout == 0
      else
        puts "command, step_mode: #{@step_mode}"
        send(command)
      end
    end

    private
    def skip_timeout delay, action
      @skip_timeout = delay
      @skip_timeout_action = action
    end

    def forward
      if !@step_mode
        if (!sensor('rr') && !sensor('ll'))
          @step_mode = 2
        else
          @step_mode = 1
        end
      end
      if @step_mode == 2
        if (sensor('rr') && sensor('ll'))
          finish_command
          return
        end
      end
      if @step_mode == 1
        if (!sensor('rr') && !sensor('ll'))
          @step_mode = 2
        end
      end
      if sensor('r') && !(sensor('r') && sensor('l'))
        @answer.right
        return
      end
      if sensor('l') && !(sensor('r') && sensor('l'))
        @answer.left
        return
      end
      @answer.start
    end

    def left
      turn 'left'
    end

    def right
      turn 'right'
    end

    def turn direction
      if @step_mode == 3
        if !sensor(TURN_SENSORS[direction])
          finish_command
        else
          @answer.send(direction)
        end
        return
      end
      if @step_mode == 2
        if sensor(TURN_SENSORS[direction])
          @step_mode = 3
        end
          @answer.send(direction)
        return
      end
      if @step_mode == 1
        if !sensor(TURN_SENSORS[direction])
          @step_mode = 2
        end
        @answer.send(direction)
        return
      end

        if sensor(TURN_SENSORS[direction])
          @step_mode = 1

        end
        @answer.send(direction)
      # end
    end

    def stop
      finish_command
    end

    def search
      if !@turn_to
        if sensor('ll')
          @turn_to = :right
        end
        if sensor('rr')
          @turn_to = :left
        end
      end
      if @step_mode == 2
        if sensor('f') && !sensor('l') && !sensor('r')
          finish_command
        else
          @answer.send(@turn_to || :left)
        end
        return
      end
      if @step_mode == 1
        if sensor('c')
          skip_timeout 20, ->{ @answer.start}
          @step_mode = 2
        end
        @answer.start
      elsif sensor('f')
        @answer.start
        @step_mode = 1
      else
        @answer.start
      end
    end

    def finish_command
      @step_mode = nil
      @answer.stop
      @commands.finish
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
