require_relative 'connection.rb'
require_relative 'helpers/packs.rb'

class Worker
  def initialize connection
    @connection = connection
    puts 'begin'

    @packs = Packs::Device.new(@connection) do |c|
      c.pack 1 => :sensors, :modules => {
        sensors: [
          { :IR_SENSOR => 2 },
          { :IR_SENSOR => 2 },
          { :IR_SENSOR => 2 },
          { :IR_SENSOR => 2 },
          { :IR_SENSOR => 2 },
        ],
        sonar: { :SR04 => 2 },
      }

      c.pack 0 => :dc_engine, :modules =>{
        motor1: { :DC_MOTOR => 0 },
        motor2: { :DC_MOTOR => 0 },
      }

      c.pack 2 => :stepper_engine, :modules =>{
        motor1: { :STEPPER_MOTOR => 0 },
        motor2: { :STEPPER_MOTOR => 0 },
      }
    end

    Thread.new do
      loop do
        @packs.stepper_engine.motor1.update(direction: [-1,1][rand(0..1)], speed: rand(20..40))
        @packs.stepper_engine.motor2.update!(direction: [-1,1][rand(0..1)], speed: rand(20..40))
        sleep(2)
      end
    end
  end

  def from_device msg
    @packs.refresh_raw(msg)

    # puts msg.bytes.inspect
    # puts @packs.sensors.sensors[2].read

    @packs.dc_engine.motor2.update(direction: 1, speed: @packs.sensors.sonar.read)
    @packs.dc_engine.motor1.update(direction: 1, speed: @packs.sensors.sonar.read)
    @packs.dc_engine.update!
  end
end

Connection.new Worker

sleep
