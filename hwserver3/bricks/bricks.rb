class Bricks
  def initialize hwid
    @hwid = hwid
    @list = []
  end

  def push brick
    @list.push brick
  end

  def push_interface brick
    @list.push brick
    @manual = brick
  end

  def manual?
    !!@manual
  end

  def interface
    @manual
  end

  def connect
    for i in 1..@list.length - 1
      @list[i-1].callback @list[i], @hwid
      @list[i].callback @list[i-1], @hwid
    end
  end

  def destroy
    @list.each do |brick|
      brick.destroy
    end
  end
end
