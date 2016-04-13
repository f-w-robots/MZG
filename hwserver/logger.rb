class Logger
  def initialize(filename)
    @filename = filename
  end

  def write message
    puts message
    File.open("log/" + @filename + ".txt", "a") do |log|
      log.puts message
    end
  end
end
