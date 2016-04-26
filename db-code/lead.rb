require_relative 'unix_connection.rb'
require_relative 'helpers/bug.rb'

@unix = UNIXConnection.new lambda {|msg| on_message(msg)}

@unix.send_message('04INIT')
@unix.send_message(BUG::Package.right_left_wheel(0,0))

def on_message msg
  Sensor.update(msg)

  result = if (Sensor.v('c') && Sensor.v('r') && Sensor.v('l')) ||
      (Sensor.v('c') && !Sensor.v('r') && !Sensor.v('l'))
    BUG::Package.right_left_wheel(-1,-1)
  elsif sensor['l']
    BUG::Package.right_left_wheel(-1,0)
  elsif sensor['r']
    BUG::Package.right_left_wheel(0,-1)
  elsif sensor['ll']
    BUG::Package.right_left_wheel(1,-1)
  elsif sensor['rr']
    BUG::Package.right_left_wheel(-1,1)
  else
    BUG::Package.right_left_wheel(0,0)
  end

  @unix.send_message(result)
end

sleep
