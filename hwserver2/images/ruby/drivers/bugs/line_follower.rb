module Drivers
module Bugs
  module LineFollower
  class Logger
    def initialize
    end

    def write msg
      # puts msg
    end
  end

  class PackageGenerator
    def self.g controller_id, data, finish = true
      "#{controller_id}#{data.length}#{data}#{finish ? '~' : ''}"
    end

    def self.right_left_wheel right, left
      g(1, "#{right == 1 ? '!0"1' : (right == -1 ? '!1"0' : '!0"0')}" +
        "#{left == 1 ? '#1$0' : (left == -1 ? '#0$1' : '#0$0')}")
    end
  end

  class Sensors
    OneZeroDeliver = 4
    MaxHistory = 10

    def initialize
      @history = []
      @log = Logger.new
    end

    def update values, print = false
      @history.unshift(values)
      @history = @history[0..(MaxHistory-1)]
      if print
        @log.write "last: #{values[0..4]}"
        @log.write "medium: #{medium(0)}#{medium(1)}#{medium(2)}#{medium(3)}#{medium(4)}"
      end
    end

    def value s
      if (s == 'l' || s == 'r') && sensorRaw(s) <= OneZeroDeliver
        rev_sensor = sensorRaw(s == 'l' ? 'r' : 'l' )
        if sensorRaw(s) >= OneZeroDeliver - 2 && rev_sensor > OneZeroDeliver
          if (rev_sensor - sensorRaw(s)) > 2
            return true
          else
            return false
          end
        end
      end

      sensorRaw(s) <= OneZeroDeliver
    end

    def clear_history
      @history = @history[0..0]
    end

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
      @log = Logger.new
    end

    def stop
      @log.write '*** stop'
      @answer.push PackageGenerator.right_left_wheel(0,0)
    end

    def start
      @log.write '*** start'
      @answer.push PackageGenerator.right_left_wheel(1,1)
    end

    def back
      @log.write '*** back'
      @answer.push PackageGenerator.right_left_wheel(-1,-1)
    end

    def right
      @log.write '*** right'
      @answer.push PackageGenerator.right_left_wheel(-1,1)
    end

    def left
      @log.write '*** left'
      @answer.push PackageGenerator.right_left_wheel(1,-1)
    end

    def right_wheel
      @log.write '*** right_wheel'
      @answer.push PackageGenerator.right_left_wheel(1,0)
    end

    def left_wheel
      @log.write '*** left_wheel'
      @answer.push PackageGenerator.right_left_wheel(0,1)
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
    SEARCH_DIRECTION = :back

    def initialize sensor, answer, commands
      @sensor = sensor
      @answer = answer
      @commands = commands
      @log = Logger.new
    end

    def sensor value
      @sensor.value value
    end

    def move command
      if command.to_sym != :lead
        if !sensor('c')
          finish_command :search
        end

        if @sensor.sensorRaw('r') + @sensor.sensorRaw('c') + @sensor.sensorRaw('l') +
           @sensor.sensorRaw('rr') + @sensor.sensorRaw('ll') < 3
          @log.write "@"*500
          finish_command :crash
        end
      end

      cmd = command
      if @override_command
        cmd = @override_command
      end
      @log.write "allow_time: #{allow_time}" if @time
      @log.write "#{cmd}, step_mode: #{@step_mode}"

      send(cmd)
      @log.write '-'*12
    end

    private
    def allow_time
      if !@time[:start]
        true
      else
        Time.now.to_f - @time[:start].to_f > @time[:delta]
      end
    end

    def crash
      finish_command(nil, true)
    end

    def forward
      if @time && @time[:delay] && @time[:start]
        @time[:start] += (Time.now.to_f - @time[:delay])
        @time.delete :delay
      end
      if !@step_mode
        if (sensor('rr') || sensor('ll'))
          @step_mode = {step: -1}
          @time = {start: Time.now, delta: 1}
        else
          @time = {start: Time.now, delta: 1}
          @step_mode = {step: 0}
        end
      end

      case @step_mode[:step]
      when -1
        @log.write "r: #{sensor('r')} l: #{sensor('l')}"
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
        @log.write "r: #{sensor('r')} l: #{sensor('l')}"
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

    def lead
      a = 0
      a += 1 if(sensor('c'))
      a += 1 if(sensor('r'))
      a += 1 if(sensor('l'))
      if (a == 3 || (sensor('c') && a == 1))
        @answer.start
      elsif sensor('l')
        @answer.right_wheel
      elsif sensor('r')
        @answer.left_wheel
      elsif sensor('ll')
        @answer.left
      elsif sensor('rr')
        @answer.right
      else
        @answer.stop
      end
    end

    def left
      turn 'left'
    end

    def right
      turn 'right'
    end

    def turn direction
      case @step_mode
      when nil
        if !sensor(TURN_SENSORS[direction])
          @step_mode = 0
        end
        @answer.send(direction)
      when 0
        if sensor(TURN_SENSORS[direction])
          @step_mode = 1
        end
        @answer.send(direction)
      when 1
        if !sensor(TURN_SENSORS[direction])
          finish_command
        else
          @answer.send(direction)
        end
      end
    end

    def stop
      finish_command
    end

    def search
      if !@step_mode
        @answer.send(SEARCH_DIRECTION)
        @step_mode = {step: -1}
        return
      end

      if @step_mode[:step] == -1
        @sensor.clear_history
        @step_mode[:step] = 0
      end

      if @step_mode[:step] == 2
        @answer.send(@step_mode[:turn])
        if @step_mode[:turn] == :left && !sensor('l')
          finish_command(:forward)
        elsif @step_mode[:turn] == :right && !sensor('r')
          finish_command(:forward)
        end
        return
      end

      if @step_mode[:step] == 1
        if sensor('c')
          @step_mode[:step] = 2
          @answer.send(@step_mode[:turn])
        else
          @answer.send(SEARCH_DIRECTION)
        end
      end

      if @step_mode[:step] == 0 && (sensor('l') || sensor('r'))
        if @sensor.sensorRaw('l') > @sensor.sensorRaw('r')
          @step_mode[:turn] = :left
        else
          @step_mode[:turn] = :right
        end

        @step_mode[:step] = 1
        @answer.send(SEARCH_DIRECTION)
      end
      if @step_mode[:step] == 0
        @answer.send(SEARCH_DIRECTION)
      end
    end

    def finish_command override_command = nil, crash = false
      @step_mode = nil
      @time = nil

      if override_command
        @override_command = override_command
        return
      end
      @override_command = nil
      @answer.stop
      @commands.finish(crash)

      @log.write "FINISH #{'-'*150}"
      @log.write "#{'#'*160}"
      @log.write "#{'#'*160}"
    end
  end

  class Main
    def initialize device
      @device = device

      @answer = Answer.new
      @sensors = Sensors.new
      @mover = Mover.new @sensors, @answer, self

      @device.out_msg_left('04INIT')
      @device.out_msg_left(PackageGenerator.right_left_wheel(0,0))

      @log = Logger.new
    end

    def finish crash = false
      @command = nil
      if crash
        @device.out_msg_right 'crash'
      else
        @device.out_msg_right 'ready'
      end
    end

    def finish?
      !@command
    end

    def command cmd
      @command = cmd
    end

    def tick msg
      puts "MSGGG: #{msg}"
      @sensors.update msg, true

      @mover.move current_command

      @device.out_msg_left(@answer.get)
      @request_time = Time.now
    end

    def current_command
      @command
    end
  end
end
end
end
