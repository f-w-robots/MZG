# Work with sensors data
#
class Sensors
  OneZeroDeliver = 2

  def update values, print = false
    @values = values
    if print
      puts "  #{@values[5]}  "
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
    elsif s == 'f'
      @values[5]
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
    @answer.push '18!1"0#1$0'
  end

  def left
    @answer.push '18!0"1#0$1'
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
      puts command
      send(command)
    end
  end

  private
  def skip_timeout delay, action
    @skip_timeout = delay
    @skip_timeout_action = action
  end

  def forward
    if @forward_mode_1
      if (!sensor('rr') && !sensor('ll'))
        finish_command
      end
      @answer.start
      return
    end
    if (sensor('rr') && sensor('ll')) || (sensor('r') && sensor('l')) && @forward_mode_0
      @forward_mode_1 = true
      @answer.start
      return
    end
    if (!sensor('rr') && !sensor('ll')) && !@forward_mode_0
      puts 'MODE0   '*30
      @forward_mode_0 = true
    end
    if sensor('r')
      @answer.right
      return
    end
    if sensor('l')
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
    if @turn_mode_2
      if sensor(TURN_SENSORS[direction])

        finish_command
      end
      @answer.send(direction)
    elsif @turn_mode_1
      if !sensor(TURN_SENSORS[direction])
        @turn_mode_2 = true
      end
      @answer.send(direction)
    else
      @answer.send(direction)
      if sensor(TURN_SENSORS[direction])
        @turn_mode_1 = true
      end
    end
  end

  def stop
    @answer.stop
  end

  def search
    if @search_mode_1a
      if sensor('f') && !sensor('l') && !sensor('r')
        finish_command
      end
      @answer.left
      return
    end
    if @search_mode_1
      if sensor('c')
        skip_timeout 20, ->{ @answer.start}
        @answer.start
        @search_mode_1a = true
      else
        @answer.start
      end
      return
    end
    if sensor('f')
      @answer.start
      puts 'SSSxxx' * 100
      @search_mode_1 = true
      return
    end
    @answer.start
  end

  def finish_command
    @forward_mode_1 = nil
    @forward_mode_0 = nil
    @turn_mode_1 = nil
    @turn_mode_2 = nil
    @commands.next
  end
end

class Commands
  def initialize list
    @list = list
    @i = 0
  end

  def next
    @i += 1
  end

  def current
    @list[@i]
  end
end

def wait_message
  while msg_empty?
    sleep 0.000001
  end
end

@answer = Answer.new
@sensors = Sensors.new
@commands = Commands.new ['forward', 'right', 'forward', 'left', 'stop']
@mover = Mover.new @sensors, @answer, @commands

puts "Start script with #{@hwid}"
socket.send('04INIT')
socket.send('18!0"0#0$0')

loop do
  wait_message

  @sensors.update shift_msg, true

  @mover.move @commands.current

  socket.send(@answer.get)
end
