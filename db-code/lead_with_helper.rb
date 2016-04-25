require_relative 'unix_connection.rb'
require_relative 'helpers/bug.rb'

@unix = UNIXConnection.new lambda {|msg| on_message(msg)}

@unix.send_message('04INIT')
@unix.send_message(PackagBUG.right_left_wheel(0,0))

def on_message msg
  Sensor.update(msg)

  result = if (Sensor.v('c') && Sensor.v('r') && Sensor.v('l')) ||
      (Sensor.v('c') && !Sensor.v('r') && !Sensor.v('l'))
    PackagBUG.right_left_wheel(-1,-1)
  elsif sensor['l']
    PackagBUG.right_left_wheel(-1,0)
  elsif sensor['r']
    PackagBUG.right_left_wheel(0,-1)
  elsif sensor['ll']
    PackagBUG.right_left_wheel(1,-1)
  elsif sensor['rr']
    PackagBUG.right_left_wheel(-1,1)
  else
    PackagBUG.right_left_wheel(0,0)
  end

  @unix.send_message(result)
end

sleep
