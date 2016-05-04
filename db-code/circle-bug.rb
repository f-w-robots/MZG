require_relative 'connection.rb'
require_relative 'helpers/bug.rb'
require_relative 'drivers/bugs/line_follower.rb'

class Worker
  def initialize connection
    @connection = connection

    @connection.mail_permission(["lh"])

    @driver = Drivers::Bugs::LineFollower::Main.new self
    puts 'forward'
    @driver.command 'forward'

    @ccc = ['left', 'forward']
  end

  def from_device msg
    @driver.tick(msg) if !@driver.finish?
  end

  def from_mail from, msg

  end

  def out_msg_left msg
    @connection.to_device(msg)
  end

  def out_msg_right msg
    if msg == 'ready'
      @driver.command @ccc[@i]
      puts @ccc[@i]
      @i += 1
      if @i == @ccc.size
        @i = 0
      end
    end
  end
end

Connection.new Worker

sleep
