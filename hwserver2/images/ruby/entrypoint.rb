require_relative 'connection.rb'
require_relative 'helpers/bug.rb'

class Worker
  def initialize connection
    @connection = connection

    @connection.to_device('message to device')
  end

  def from_device msg
    puts msg
  end
end

Connection.new Worker

sleep
