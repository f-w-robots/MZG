require 'byebug'
require 'chunky_png'

# Advanced labirint
#
# logic:
# 'u'
class Labirint2
  def initialize
    @size = 2000
    @width = @size/100
    @sdelta = @width/2
    @labirint = Labirint2Generator.new(@size, @width).labirint

    @x = @size/2
    @y = @size/2

    painter = Labirint2Painer.new(@labirint)
    painter.paint
  end

  def size
    @size
  end

  def labirint
    @labirint
  end

  def sensors
    # eswn
    result = [0,0,0,0]
    (@x..@x + @sdelta).each do |x|
      if labirint[x][@y] == 1
        result[0] = 1
      end
    end
    (@x - @sdelta..@x).each do |x|
      if labirint[x][@y] == 1
        result[2] = 1
      end
    end
    (@y..@y + @sdelta).each do |y|
      if labirint[@x][y] == 1
        result[1] = 1
      end
    end
    (@y - @sdelta..@y).each do |y|
      if labirint[@x][y] == 1
        result[3] = 1
      end
    end
    result
  end

  def command direction
    # puts direction
    nx = @x
    ny = @y
    case direction
    when 'r'
      nx = @x + 1
    when 'd'
      ny = @y + 1
    when 'l'
      nx = @x - 1
    when 'u'
      ny = @y - 1
    end
    # puts "#{@x} #{@y}"
    # puts check_point(nx, ny)
    if check_point nx, ny
      @x = nx
      @y = ny
    end
    puts "#{@x} #{@y}"
  end

  def check_point x, y
    x >= 0 && x < @size && y >= 0 && y < @size && @labirint[x][y] == 0
  end
end

class Labirint2Generator
  def initialize size, width
    @size = size
    @labirint = Array.new(@size){Array.new(@size){1}}

    3.times do

      continue = true
      @x = @size/2
      @y = @size/2

      i = 0
      loop do
        break if !continue

        if i % (rand(@size/2).round + 1) == 0
          rand_direction
        end

        i += 1
        continue = move_to_direction

        ((@x-width)..(@x+width)).each do |x|
          ((@y-width)..(@y+width)).each do |y|
            if x >= 0 && x < @size && y >= 0 && y < @size
              @labirint[x][y] = 0
            end
          end
        end
      end
    end
  end

  def labirint
    @labirint
  end

  def rand_direction
    @dx = (rand * 3 - 1.4999).round
    @dy = (rand * 3 - 1.4999).round
  end

  def move_to_direction
    nx = @x + @dx
    ny = @y + @dy

    if nx >= 0 && nx < @size
      @x = nx
      a = true
    end
    if ny >= 0 && ny < @size
      @y = ny
      b = true
    end
    a && b
  end

  def size
    @size
  end
end

class Labirint2Painer
  def initialize labirint
    @labirint = labirint
  end

  def paint
    png = ChunkyPNG::Image.new(@labirint.size, @labirint.size, ChunkyPNG::Color::TRANSPARENT)
    @labirint.each_with_index do |row, i|
      row.each_with_index do |v, j|
        if v == 1
          png[i,j] = ChunkyPNG::Color.rgba(0, 0, 0, 255)
        elsif v == 2
          png[i,j] = ChunkyPNG::Color.rgba(0, 255, 0, 255)
        else
          png[i,j] = ChunkyPNG::Color.rgba(255, 255, 255, 255)
        end
      end
    end
    png.save('filename.png', :interlace => true)
  end
end

# a = Labirint2.new
# png = ChunkyPNG::Image.new(a.size, a.size, ChunkyPNG::Color::TRANSPARENT)
# a.labirint.each_with_index do |row, i|
#   row.each_with_index do |v, j|
#     if v == 1
#       png[i,j] = ChunkyPNG::Color.rgba(0, 0, 0, 255)
#     elsif v == 2
#       png[i,j] = ChunkyPNG::Color.rgba(0, 255, 0, 255)
#     else
#       png[i,j] = ChunkyPNG::Color.rgba(255, 255, 255, 255)
#     end
#   end
# end
# png.save('filename.png', :interlace => true)
# # debugger
# # a
