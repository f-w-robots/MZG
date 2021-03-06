module BUG
  class PackageBin
    def self.g controller_id, data
      ([controller_id, data.size] + data).pack('c*')
    end

    def self.right_left_wheel right, left
      g(1, ["0000#{right == 1 ? '1' : '0'}#{right == -1 ? '1' : '0'}#{left == 1 ? '1' : '0'}#{left == -1 ? '1' : '0'}".to_i(2)])
    end

    def self.init
      [29].pack('c*')
    end

    # def self.calibrate threshold
    #   if threshold == :down || threshold == :black
    #     self.g(1, "%1")
    #   elsif threshold == :up || threshold == :white
    #     self.g(1, "%2")
    #   else
    #     raise "Unknow threshold: #{threshold}"
    #   end
    # end
    #
    # def self.setSensorsCount count
    #   if count > 9 || count < 1
    #     raise "Count"
    #   end
    #   g(1, "&#{count}")
    # end
  end

  class Package
    def self.g controller_id, data
      "#{controller_id}#{data.length}#{data}"
    end

    def self.right_left_wheel right, left
      g(1, "#{right == 1 ? '!0"1' : (right == -1 ? '!1"0' : '!0"0')}" +
        "#{left == 1 ? '#1$0' : (left == -1 ? '#0$1' : '#0$0')}")
    end

    def self.calibrate threshold
      if threshold == :down || threshold == :black
        self.g(1, "%1")
      elsif threshold == :up || threshold == :white
        self.g(1, "%2")
      else
        raise "Unknow threshold: #{threshold}"
      end
    end

    def self.setSensorsCount count
      if count > 9 || count < 1
        raise "Count"
      end
      g(1, "&#{count}")
    end
  end

  class Sensor
    def self.update msg
      @@msg = msg
    end

    def self.v s
      if s == 'rr'
        @@msg[4].to_i < 4
      elsif s == 'll'
        @@msg[0].to_i < 4
      elsif s == 'r'
        @@msg[3].to_i < 4
      elsif s == 'l'
        @@msg[1].to_i < 4
      elsif s == 'c'
        @@msg[2].to_i < 4
      end
    end
  end
end
