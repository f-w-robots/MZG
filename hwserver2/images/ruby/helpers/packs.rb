module Packs
  module Mods
    class Base
      def initialize position, pack
        @pack = pack
        @position = position
      end

      def update! params
        update params
        @pack.update!
      end

      def read
        @value
      end

      def default
        0
      end

      def refresh data
        @value = data
      end
    end

    class SR04 < Base

    end

    class STEPPER_MOTOR < Base
      def update params
        direction = params[:direction]
        speed = params[:speed]
        speed = 0 if speed < 0
        speed = 63 if speed > 63

        data = "#{speed.to_s(2).rjust(6, "0")}#{direction > 0 ? '1' : '0'}#{direction < 0 ? '1' : '0'}"
        @pack.set(@position, data.to_i(2))
      end
    end

    class DC_MOTOR < STEPPER_MOTOR

    end

    class IR_SENSOR < Base

    end
  end

  class Pack
    def initialize pack_id, connection, modules
      @id = pack_id
      @connection = connection

      @package = []

      @tree = {}

      @position = 0
      modules.each do |name, mod|
        if mod.is_a? Array
          @tree[name] = []
          mod.each do |mod|
            @tree[name].push create_mod(mod)
          end
        else
          @tree[name] = create_mod(mod)
        end
      end
    end

    def set position, value
      @package[position] = value
    end

    def update!
      data = ([@id] + @package).pack('c*')
      @connection.to_device(data)
    end

    def refresh data
      @tree.values.flatten.each_with_index do |mod, index|
        mod.refresh(data[index])
      end
    end

    def method_missing(method_sym, *arguments, &block)
      @tree[method_sym] ? @tree[method_sym] : super
    end

    private
    def create_mod mod_name
      mod = Mods.const_get(mod_name).new @position, self
      @package[@position] = mod.default
      @position += 1
      mod
    end
  end

  class Device
    def initialize connection
      @connection = connection

      @tree = {}

      if block_given?
        yield(self)
      end
    end

    def pack params
      pack_name = params.first[1]
      pack_id = params.first[0]
      @tree[pack_name] = Pack.new(pack_id, @connection, params[:modules])
    end

    def method_missing(method_sym, *arguments, &block)
      @tree[method_sym] ? @tree[method_sym] : super
    end

    def refresh_raw data
      refresh(data.bytes)
    end

    def refresh data
      @tree.values[data[0]].refresh(data[1..-1])
    end
  end
end
