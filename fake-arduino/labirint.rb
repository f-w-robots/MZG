# Source code in MZG/db-code/fake-labirint.*
#
class Labirint
  def initialize
    generate
    @x = 0
    @y = 1
    @angle = 1
  end

  # Move current point in the direction as 'f' - forward, 'r' - right, 'l' - left, 'b' - back
  def command direction
    ny, nx, nangle = near_xy(direction)
    if @labirint[ny][nx] == 0 || @labirint[ny][nx] == 2
      @x = nx
      @y = ny
      print
      @angle = nangle % 4
    end
  end

  # Check wall in the direction as 'f' - forward, 'r' - right, 'l' - left, 'b' - back
  def sensors
    result = []
    ['f','r',nil,'l'].each do |d|
      if !d
        result << nil
        next
      end
      ny, nx = near_xy(d)
      result << @labirint[ny][nx]
    end
    result
  end

  private
  def generate
    @labirint = [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1, 0,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
      [1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1],
      [1,1,0,1,0,1,0,0,0,1,0,0,0,0,0,1],
      [1,0,0,0,0,1,0,0,0,0,0,1,1,1,0,1],
      [1,1,1,0,1,1,0,1,1,1,0,1,0,0,0,1],
      [1,0,0,0,0,0,0,1,1,1,0,1,1,1,1,1],
      [1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 2],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ]
  end

  # Get xy depend direction and considering angle
  def near_xy direction
    nx = @x
    ny = @y
    delta = ["ny -= 1", "nx += 1", "ny += 1", "nx -= 1"]
    @angle.times{delta.push delta.shift}
    direction_index = ['f','r','b','l'].index(direction)
    eval(delta[direction_index])
    nangle = @angle + direction_index
    return ny, nx, nangle
  end
end
