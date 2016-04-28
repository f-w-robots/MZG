require_relative 'connection.rb'
require_relative 'helpers/bug.rb'

class Worker
  def initialize connection
    @connection = connection

    @connection.to_device('04INIT')
    @connection.to_device(BUG::Package.right_left_wheel(0,0))
  end

  def from_device msg
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

    @Connection.to_device(result)
  end
end

Connection.new Worker

sleep
