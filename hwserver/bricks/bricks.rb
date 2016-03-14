class Bricks
  def initialize hwid
    @hwid = hwid
    @list = []
  end

  def push brick
    @list.push brick
  end

  def push_interface brick
    return if group_interface?
    @list.push brick
    @manual = brick
  end

  def push_group group
    @group = group
  end

  def manual?
    (group_interface? || !!@manual)
  end

  def group_interface?
    @group && @group.interface?
  end

  def interface
    @manual
  end

  def connect
    for i in 0..@list.length - 1
      if i-1 >= 0
        @list[i].callback_left(@list[i-1], @hwid)
      end
      if i+1 < @list.length
        @list[i].callback_right(@list[i+1], @hwid)
      end
    end
  end

  def destroy
    @list.each do |brick|
      brick.destroy
    end
  end
end
