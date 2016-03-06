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
  sensorRaw(s) <= 4
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
  else
    start
  end
end

def move_right
  if @r1
    if sensor('rr') && sensor('ll')
      stop
      next_step
    else
      right
    end
  else
    if !sensor('rr') && !sensor('ll')
      @r1 = true
    end
    right
  end
end

def move_stop
  stop
end


puts "Start script with #{@hwid}"
socket.send('04INIT')
socket.send('18!0"0#0$0')

@answer = []
@steps = ['forward', 'right', 'stop']
@steapNumebr = 0

loop do
  while msg_empty?
    sleep 0.000001
  end

  a = shift_msg
  puts "  #{a[5]}  "
  puts a[0..4]
  puts '-'*10
  @sensorsValues = a

  puts current_step
  send(:"move_#{current_step}")

  if @answer.size != 1
    raise("end loop, @answers count #{@answer.size}")
  else
    socket.send(@answer.shift)
  end
end
