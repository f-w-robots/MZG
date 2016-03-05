@answer = []
# 'r', 'l', 'rr', 'll', 'c', 'f'
def sensorRaw s
  if s == 'rr'
    sensorsValues[4]
  elsif s == 'll'
    sensorsValues[0]
  elsif s == 'r'
    sensorsValues[3]
  elsif s == 'l'
    sensorsValues[1]
  elsif s == 'c'
    sensorsValues[2]
  elsif s == 'f'
    sensorsValues[5]
  end
end

def sensor s
  sensorRaw(s) >= 4
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

puts "Start script with #{@hwid}"

socket.send('04INIT')
socket.send('18!1"0#0$1')

loop do
  while msg_empty?
    sleep 0.000001
  end

  sensorsValues = shift_msg

  # if sensor('rr') && sensor('ll')
  #   stop
  # end
  start

  if @answer.size != 1
    raise("end loop, @answers count #{@answer.size}")
  else
    puts sensorsValues
    socket.send(@answer.shift)
  end
end
