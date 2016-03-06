def wait_message
  while msg_empty?
    sleep 0.000001
  end
end

def get_and_print_sensors
  @sensorsValues = shift_msg
  puts "  #{@sensorsValues[5]}  "
  puts @sensorsValues[0..4]
  puts '-'*10
end

# 'r', 'l', 'rr', 'll', 'c', 'f'
def sensorRaw s
  (if s == 'rr'
    @sensorsValues[4]
  elsif s == 'll'
    @sensorsValues[0]
  elsif s == 'r'
    @sensorsValues[3]
  elsif s == 'l'
    @sensorsValues[1]
  elsif s == 'c'
    @sensorsValues[2]
  elsif s == 'f'
    @sensorsValues[5]
  end).to_i
end

def sensor s
  sensorRaw(s) <= 2
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

def current_step
  @steps[@steapNumebr]
end

def next_step
  @steapNumebr += 1
end

def move_forward
  if sensor('rr') && sensor('ll')
    stop
    next_step
    return
  end
  if sensor('r')
    right
    return
  end
  if sensor('l')
    left
    return
  end
  start
end

def move_left
  move_turn 'left'
end

def move_right
  move_turn 'right'
end

def move_turn direction
  if @r1
    if sensor('rr')
      @r1a = true
    end
    if sensor('ll')
      @r1b = true
    end
    if @r1a && @r1b
      stop
      next_step
    else
      send(direction)
    end
  else
    if !sensor('rr') && !sensor('ll')
      @r1 = true
    end
    send(direction)
  end
end

def move_stop
  stop
end

def move_search
  if @search_mode_1a
    if sensor('f') && !sensor('l') && !sensor('r')
      next_step
    end
    left
    return
  end
  if @search_mode_1
    if sensor('c')
      @skip_timeout = 20
      start
      @search_mode_1a = true
    else
      start
    end
    return
  end
  if sensor('f')
    start
    puts 'SSSxxx' * 100
    @search_mode_1 = true
    return
  end
  start
end


puts "Start script with #{@hwid}"
socket.send('04INIT')
socket.send('18!0"0#0$0')

@answer = []
@steps = ['forward', 'left', 'stop']
# @steps = ['forward', 'stop']
# @steps = ['search', 'forward']
# @steps = ['stop']
@steapNumebr = 0

loop do
  wait_message

  get_and_print_sensors

  if(@skip_timeout)
    @skip_timeout -= 1
    start
    if(@skip_timeout == 0)
      @skip_timeout = nil
      puts 'ENDTOMOut' * 100
    end
  else
    puts current_step
    send(:"move_#{current_step}")
  end

  if @answer.size != 1
    raise("end loop, @answers count #{@answer.size}")
  else
    socket.send(@answer.shift)
  end
end
