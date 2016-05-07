require_relative 'connection.rb'
require_relative 'helpers/bug.rb'

class Worker
  def initialize connection
    @connection = connection

    @connection.to_device('04INIT')
    @connection.to_device(BUG::Package.right_left_wheel(0,0))
  end

  def from_device msg
    BUG::Sensor.update(msg)

    result = if (BUG::Sensor.v('c') && BUG::Sensor.v('r') && BUG::Sensor.v('l')) ||
        (BUG::Sensor.v('c') && !BUG::Sensor.v('r') && !BUG::Sensor.v('l'))
      BUG::Package.right_left_wheel(-1,-1)
    elsif BUG::Sensor.v('l')
      BUG::Package.right_left_wheel(-1,0)
    elsif BUG::Sensor.v('r')
      BUG::Package.right_left_wheel(0,-1)
    elsif BUG::Sensor.v('ll')
      BUG::Package.right_left_wheel(1,-1)
    elsif BUG::Sensor.v('rr')
      BUG::Package.right_left_wheel(-1,1)
    else
      BUG::Package.right_left_wheel(0,0)
    end

    @connection.to_device(result)
  end
end

Connection.new Worker

sleep
