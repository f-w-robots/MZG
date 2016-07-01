require_relative 'connection.rb'
require_relative 'helpers/bug.rb'
require_relative 'helpers/package.rb'
require_relative 'helpers/packs.rb'

class Worker
  def initialize connection
    @connection = connection
    puts 'begin'

    @packs = Packs.new(@connection) do |c|
      c.pack 0 => :sensors, :modules => {
        sonar: :SR04,
        sensors: [:IR_SENSOR, :IR_SENSOR, :IR_SENSOR, :IR_SENSOR, :IR_SENSOR],
      }

      c.pack 1 => :dc_engine, :modules =>{
        motor1: :DC_MOTOR,
        motor2: :DC_MOTOR,
      }
    end

    @packs.dc_engine.motor1.update(direction: 1, speed: 60)
    @packs.dc_engine.motor2.update!(direction: 1, speed: 60)
  end

  def from_device msg
    @packs.refresh_raw(msg)
    puts @packs.sensors.sonar.read
    @packs.dc_engine.motor1.update(direction: 1, speed: @packs.sensors.sonar.read)
    @packs.dc_engine.motor2.update(direction: 1, speed: @packs.sensors.sonar.read)
    @packs.dc_engine.update!
  end
end

Connection.new Worker

sleep
