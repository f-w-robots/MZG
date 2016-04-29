class Mailer
  def initialize
    @devices = {}
    @permissions = {}
  end

  def register hwid, device
    @devices[hwid] = device
  end

  def raw from, data
    if(data.start_with?(29.chr))
      @permissions[from] = data.split(29.chr)
      @permissions[from].shift
    else
      to, message = data.split(30.chr, 2)
      send_mail(from: from, to: to, message: message)
    end
  end

  private
  def send_mail opts
    return if !@devices[opts[:to]]
    return if !(@permissions[opts[:to]] && @permissions[opts[:to]].include?(opts[:from]))
    to = @devices[opts[:to]]
    to.recive_mail(opts[:from], opts[:message])
  end
end
