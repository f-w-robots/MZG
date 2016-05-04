require_relative 'connection.rb'

class Worker
  def initialize connection
    @connection = connection

    next_step
  end

  def next_step
    if @last_command == 'forward'
      @connection.to_device('left')
      @last_command = 'left'
    else
      @connection.to_device('forward')
      @last_command = 'forward'
    end
  end

  def from_device msg
    next_step if msg == 'ready'
  end
end

Connection.new Worker

sleep
