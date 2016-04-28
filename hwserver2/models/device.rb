class Device
  attr_reader :record

  def initialize device_record, manager
    @hwid = device_record.hwid
    @log = Logger.new(@hwid)

    @threads = {}

    @manager = manager
    @record = device_record

    @path = "#{Dir.pwd}/containers/#{@hwid}"

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

  private
  def start_logging
    Thread.new do
      @container.streaming_logs(follow: true, stdout: true, stderr: true) do |stream, message|
        @manager.new_output @hwid, stream, message
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
  end

  def message_from_container msg
    puts "MSG to DEVICE: #{msg}"
    @ws.send(msg)
  end

  def start_ping_thread time, timeout
    @threads[:ping].terminate if @threads[:ping]
    @threads[:ping] = Thread.new do
      loop do
        sleep 5
        if @wait_pong
          @log.write "ABORTED by PING-PONG"
          destroy
          break
        end
        @ws.ping(body = '')
        @wait_pong = true
      end
    end
  end

  def open_websocket
    @record.request.websocket do |ws|
      @ws = ws

      ws.onopen do
        puts "connected with id: #{@hwid}"
        if ws.pingable?
          start_ping_thread 5, 3
          puts "PING-PONG supported"
        else
          puts "PING-PONG not supported"
        end
      end

      ws.onmessage do |msg|
        puts "MSG from DEVICE: #{msg}, #{(msg || "").bytes.map{|a|a.to_s(16)}}"
        begin
          @unix.send_message(msg)
        rescue
          @ws.close_connection
        end
      end

      ws.onclose do
        puts "disconnected with id: #{@hwid}"
        destroy
      end

      ws.onpong do
        @wait_pong = false
        puts "PING-PONG"
      end
    end
  end

  def destroy
    @container.stop
    @manager.disconnected(self)
    @threads.each do |name, thread|
      thread.terminate
    end
  end
end
