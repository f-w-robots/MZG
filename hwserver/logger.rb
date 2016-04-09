class Logger
  DIR = 'logs'
  def initialize

  end

  def self.device hwid, msg
    if !(file = @@device_files[hwid])
      @@device_files[hwid] = file = File.open("#{DIR}/deice.#{hwid}.log", 'a')
    end
    file.write(msg)
  end

end
