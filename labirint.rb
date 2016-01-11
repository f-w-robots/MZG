# Simple labirint
#
class Labirint
  def initialize
    generate
    @x = 0
    @y = 1
    @angle = 1
  end

  # Move current point in the direction as 'f' - forward, 'r' - right, 'l' - left, 'b' - back
  def move direction
    ny, nx, nangle = near_xy(direction)
    if @labirint[ny][nx] == 0
      @x = nx
      @y = ny
      @angle = nangle % 4
    elsif @labirint[ny][nx] == 2
      @finished = true
    end
  end

  # Check wall in the direction as 'f' - forward, 'r' - right, 'l' - left, 'b' - back
  def detector direction
    ny, nx = near_xy(direction)
    @labirint[ny][nx]
  end

  private
  def generate
    @labirint = [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1, 0,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
      [1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1],
      [1,1,0,1,0,1,0,0,0,1,0,0,0,0,0,1],
      [1,0,0,0,0,1,0,1,0,0,0,1,1,1,0,1],
      [1,1,1,0,1,1,0,1,1,1,0,1,0,0,0,1],
      [1,0,1,0,0,0,0,1,1,1,0,1,1,1,1,1],
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
