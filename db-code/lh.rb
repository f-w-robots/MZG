require_relative 'connection.rb'

class Worker
  def initialize connection
    @connection = connection

    @cards = {}

    @registred_hwids = []

    @dict = {
      ["93", "87", "8c", "65"] => "bug3",
      ["65", "7C", "8C", "65"] => "bug2",
    }

    puts 'inited'
    @connection.to_device("0")
  end

  def from_device msg
    if(msg.start_with?('id:'))
      hwid = msg.sub('id:','')
      puts hwid
      if !@registred_hwids.include?(hwid)
        @dict.each do |card, device|
          if device == hwid && @cards.has_key?(card)
            @cards[card] = hwid
            @registred_hwids.push hwid
            @connection.to_device("0" + @registred_hwids.join(10.chr))
            puts @registred_hwids.join(13.chr).inspect
            puts "Assign #{hwid} to #{card}"
          end
        end

        if !@registred_hwids.include?(hwid)
          puts "No free cards for #{hwid}"
        end
      else
        puts "skip #{hwid}"
      end
    else
      card_id = uuid(msg)
      # puts "#{rand(1000)}card: #{card_id}"
      if(!@cards.has_key?(card_id) && card_id != ["c", "39", "ff", "3f"])
        puts "New card: #{card_id}"
        @cards[card_id] ||= nil
      end

      if @cards.has_key?(card_id) && @cards[card_id]
        puts "MAIL to #{@cards[card_id]}"
        @connection.mail_to(@cards[card_id], 'card')
      end
    end
  end

  private
  def uuid msg
    msg.bytes.map{|a|a.to_s(16)}
  end
end

Connection.new Worker

sleep
