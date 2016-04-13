module PackageGenerator
  class G
    def self.g controller_id, data, finish = true
      "#{controller_id}#{data.length}#{data}#{finish ? '~' : ''}"
    end
  end

  class BUG
    def self.right_left_wheel right, left
      G.g(1, "#{right == 1 ? '!0"1' : (right == -1 ? '!1"0' : '!0"0')}" +
        "#{left == 1 ? '#1$0' : (left == -1 ? '#0$1' : '#0$0')}")
    end
  end
end
