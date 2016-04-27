module BUG
  class Package
    def self.g controller_id, data, finish = true
      "#{controller_id}#{data.length}#{data}#{finish ? '~' : ''}"
    end

    def self.right_left_wheel right, left
      g(1, "#{right == 1 ? '!0"1' : (right == -1 ? '!1"0' : '!0"0')}" +
        "#{left == 1 ? '#1$0' : (left == -1 ? '#0$1' : '#0$0')}")
    end
  end

  class Sensor
    def self.update msg
      @@msg = msg
    end

    def self.v s
      if s == 'rr'
        @@msg[4]
      elsif s == 'll'
        @@msg[0]
      elsif s == 'r'
        @@msg[3]
      elsif s == 'l'
        @@msg[1]
      elsif s == 'c'
        @@msg[2]
      end
    end
  end
end
