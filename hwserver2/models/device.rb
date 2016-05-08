class Device
  attr_reader :record

  def initialize device_record, manager, mailer
    @hwid = device_record.hwid
    @log = Logger.new(@hwid)

    @threads = {}

    @manager = manager
    @record = device_record

    @path = "#{Dir.pwd}/containers/#{@hwid}"

    @mailer = mailer
    @mailer.register(@hwid, self)

    start_container
  end

  def start_container
    create_container('ruby')
    prepare_volume('ruby')
    open_sockets
    @container.start!
    start_logging
  end

  def recreate_container
    @container.stop

    start_container
  end

  def start
    open_websocket
  end

  def recive_mail from, message
    begin
      @mail.send_message("#{from}#{30.chr}#{message}")
    rescue

    end
  end

  private
  def start_logging
    @threads[:logging] = Thread.new do
      begin
        @container.streaming_logs(follow: true, stdout: true, stderr: true) do |stream, message|
          @manager.new_output @hwid, stream, message
        end
      rescue Docker::Error::TimeoutError

      end
    end
  end

  def prepare_volume lang, save_sockets = false
    Dir.mkdir(@path) if !File.exists?(@path)
    Dir["#{@path}/*"].each do |file|
      if !(Pathname.new(file).basename.to_s.start_with?('socket') && save_sockets)
        File.unlink(file) if !File.directory?(file)
      end
    end

    basepath = "#{Dir.pwd}/images/#{lang}"
    Dir["#{basepath}/**/*"].each do |fname|
      nfname = fname.sub(basepath, '')
      if File.directory?(fname)
        Dir.mkdir("#{@path}/#{nfname}") if !File.exists?("#{@path}/#{nfname}")
      else
        FileUtils.cp fname, "#{@path}/#{nfname}"
      end
    end

    if lang == 'ruby'
      File.open("#{@path}/entrypoint.rb", 'w') { |file| file.write(@record.algorithm) }
    end
  end

  def create_container lang
    image = Docker::Image.build_from_dir('images/', { 'dockerfile' => "Dockerfile.#{lang}" })

    @container = Docker::Container.create(
      "Image" => image.id,
      "Binds" => ["#{@path}/:/app"],
      'Cmd' => ['ruby', 'entrypoint.rb' ]
    )
  end

  def open_sockets
    @unix = UNIXConnection.new "#{@path}/socket.server", "#{@path}/socket", lambda {|msg| message_from_container(msg)}
    @mail = UNIXConnection.new "#{@path}/socket.mail.server", "#{@path}/socket.mail", lambda {|msg| message_from_container_by_mail(msg)}
  end

  def message_from_container msg
    puts "MSG to DEVICE: #{msg}"
    EM.next_tick {@ws.send(msg)}
  end

  def message_from_container_by_mail msg
    puts "FROM container BY mail #{msg}"
    @mailer.raw(@hwid, msg)
  end

  def start_ping_thread delay, ws
    @threads[:ping] = Thread.new do
      wait_pong = nil
      loop do
        sleep delay
        if wait_pong
          ws.instance_eval{@stream}.instance_eval{@rack_hijack_io_reader}.close_connection
          puts 'ABORT by ping-pong'
        end
        wait_pong = true
        puts "PING"
        ws.ping
        ws.ping(body = '') do
          puts "PONG"
          wait_pong = false
        end
      end
    end
  end

  def open_websocket
    ws = Faye::WebSocket.new(@record.request.env)
    @ws = ws
    ws.on(:open) do
      puts "connected with id: #{@hwid}"
      start_ping_thread 5, ws
    end

    ws.on(:message) do |msg|
      puts "MSG from DEVICE: #{msg.data}"
      begin
        @unix.send_message(msg.data)
      rescue
        @ws.close_connection
      end
    end

    ws.on(:close) do |event|
      puts "disconnected with id: #{@hwid}"
      destroy
    end

    ws.rack_response
  end

  def destroy
    @container.stop
    @manager.disconnected(self)
    @threads.each do |name, thread|
      thread.terminate
    end
  end
end
