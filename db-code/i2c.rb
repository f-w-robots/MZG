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

  def value s
    sensorRaw(s) <= OneZeroDeliver
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

def wait_message
  while msg_empty?
    sleep 0.000001
  end
end

@next_step_after_skip = false

class Mover
  def initialize sensor, answer, commands
    @sensor = sensor
    @answer = answer
    @commands = commands
  end

  def sensor value
    @sensor.value value
  end

  def move_forward
    if @forward_mode1
      if (!sensor.value('rr') && !sensor('ll'))
        @commands.next
      end
      @answer.start
    end
    if (sensor('rr') && sensor('ll')) || (sensor('r') && sensor('l'))
      @forward_mode1 = true
      @answer.start
      @commands.next
      return
    end
    if sensor('r')
      @answer.start
      return
    end
    if sensor('l')
      @answer.start
      return
    end
    @answer.start
  end

  def move_left
    move_turn 'left'
  end

  def move_right
    move_turn 'right'
  end

  def move_stop
    @answer.stop
  end

  def move_search
    if @search_mode_1a
      if sensor('f') && !sensor('l') && !sensor('r')
        @commands.next
      end
      @answer.left
      return
    end
    if @search_mode_1
      if sensor('c')
        skip_timeout 20, ->{start}
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

  private
  def move_turn direction
    if @r1
      if sensor('rr')
        @r1a = true
      end
      if sensor('ll')
        @r1b = true
      end
      if @r1a && @r1b
        skip_timeout 120, ->{send(direction)}
        @answer.left
        @commands.next
      else
        @answer.send(direction)
      end
    else
      if !sensor('rr') && !sensor('ll')
        @r1 = true
      end
      @answer.send(direction)
    end
  end
end

class Commands
  def initialize
    @steps = ['forward', 'right', 'stop']
    @stepNumebr = 0
  end

  def next
    @stepNumebr += 1
  end

  def current
    @steps[@stepNumebr]
  end
end

def skip_timeout delay, action
  @skip_timeout = delay
  @skip_timeout_action = action
end

def stop!
  @steps = ['stop']
  @steapNumebr = 0
  @exit = true
  puts 'STOP___'*10
end

@answer = Answer.new
@sensors = Sensors.new
@commands = Commands.new
@mover = Mover.new @sensors, @answer, @commands

puts "Start script with #{@hwid}"
socket.send('04INIT')
socket.send('18!0"0#0$0')

loop do
  wait_message

  @sensors.update shift_msg, true

  if(@skip_timeout)
    @skip_timeout -= 1
    @skip_timeout_action.call
    @skip_timeout = nil if @skip_timeout == 0
  else
    puts @commands.current
    @mover.send(:"move_#{@commands.current}")
  end

  socket.send(@answer.get)

  if @exit
    break
  end
end
