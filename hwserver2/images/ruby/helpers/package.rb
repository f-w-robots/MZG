class Package
  def initialize module_id
    @package = [module_id]
  end

  def add device, *args
    send("add_#{device}", *args)
  end

  def result
    @package.pack('c*')
  end

  private
  def add_28byj_motor params
    direction = params[:direction]
    speed = params[:speed]
    speed = 0 if speed < 0
    speed = 63 if speed > 63

    data = "#{speed.to_s(2).rjust(6, "0")}#{direction > 0 ? '1' : '0'}#{direction < 0 ? '1' : '0'}"
    @package.push(data.to_i(2))
  end

  def add_dc_motor params
    direction = params[:direction]
    speed = params[:speed]
    speed = 0 if speed < 0
    speed = 63 if speed > 63

    data = "#{speed.to_s(2).rjust(6, "0")}#{direction > 0 ? '1' : '0'}#{direction < 0 ? '1' : '0'}"
    @package.push(data.to_i(2))
  end
end
