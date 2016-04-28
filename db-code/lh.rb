require_relative 'connection.rb'

class Worker
  def initialize connection
    @connection = connection

    @cards = {}
  end

  def from_device msg
    if(msg.start_with?('id:'))
      id = msg.sub('id:','')
      @cards.each do |card, device|
        if !device
          @cards[card] = msg
          @connection.to_device("0" + id)
          puts "#{card.bytes.map{|a|a.to_s(16)}.inspect}}: #{id}"
          break
        end
      end
    else
      if(!@cards.has_key?(msg))
        puts "New card: #{msg.bytes.map{|a|a.to_s(16)}.inspect}"
      end
      @cards[msg] ||= nil
    end
  end
end

Connection.new Worker

sleep
