# Simple labirint
#
###############
# HTML code for manual control:
#
# <div class="controlBlock">
#   <button class="f">forward</button>
#   <button class="l">left</button>
#   <button class="r">right</button>
#   <button class="b">back</button>
# </div>
#
#
# <script type="text/javascript">
#     $('.controlBlock button').click(function(event) {
#         socket.send(event.target.className);
#     });
# </script>
###############
# Algorithm on ruby:
#
# loop do
# while msg_empty?
#   sleep(0.1)
# end
# msg = shift_msg
# result = if msg[3] == '2'
#   'ls'
# elsif msg[0] == '2'
#   'fs'
# elsif msg[1] == '2'
#   'rs'
# else
#   if msg[3] == '0'
#     'l'
#   elsif msg[0] == '0'
#     'f'
#   elsif msg[1] == '0'
#     'r'
#   else
#     'b'
#   end
# end
# socket.send(result)
# end
###############
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
