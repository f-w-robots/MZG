# Server for devices
#
# Accepts connections from devices by web-sockets
# and control devices through the connections
#
require 'byebug'
Thread::abort_on_exception = true

require 'json'
require 'sinatra'
require 'sinatra-websocket'
require 'mongo'

require_relative 'algorithm_backend'
require_relative 'device_websocket'
require_relative 'manual_backend'
require_relative 'group_backend'

get '/devices/list/manual' do
  response.headers['Access-Control-Allow-Origin'] = '*'
  {keys: settings.manual_hwsockets.keys}.to_json
end

get '/group/info/:name' do |name|
  response.headers['Access-Control-Allow-Origin'] = '*'
  group = settings.groups[name]
  if !group
    status 404
    return
  end
  group.options[:info].to_s
end

class Group
  def initialize hwsockets, record
    @hwsockets = hwsockets
    @record = record

    @rounds = record[:options][:rounds].to_i
    @timeout = record[:options][:timeoutM].to_i * 60 + record[:options][:timeoutS].to_i

    @options = {}
    @options[:commands] = {}
    @options[:info] = {}

    @messages = {}
  end

  def start
    @thread = Thread.new do
      for round in 1..@rounds
        theend = Time.now + @timeout
        allow_accept
        loop do
          sleep 0.001
          @options[:info][:timout] = theend - Time.now
          if theend < Time.now
            allow_accept(false)
            @options[:commands].keys.each do |key|
              @options[:commands][key].each do |command|
                @hwsockets[key].direct_on_message command
                @messages[key] ||= 0
                @messages[key] += 1
              end
            end

            # Wait responses
            while true
              puts @messages
              count = 0
              @messages.each do |k, v|
                count += v
              end
              break if count <= 0
              sleep 1
            end

            allow_accept

            if round >= @rounds
              finish
              destroy
            end
          end
        end
      end
    end
  end

  def allow_accept yes = true
    @options[:info][:accept] = yes
  end

  def accept?
    @options[:info][:accept]
  end

  def on_message hwid, msg
    puts 'income ' + hwid
    if accept?
      puts 'accept ' + hwid
      @options[:commands][hwid] ||= []
      @options[:commands][hwid] << msg
    end
  end

  def destroy
    @thread.terminate
  end

  def options
    @options
  end

  def message_from_device hwid, msg
    @options[:info][:score] ||= {}
    @options[:info][:score][hwid] ||= 0
    @options[:info][:score][hwid] += 1
    clear_stack hwid, msg
  end

  private
  def clear_stack hwid, msg
    if @messages[hwid]
      if msg == 'crash' || msg == 'win'
        @messages[hwid] = 0
      else
        @messages[hwid] -= 1
      end
    end
  end

  def finish
    max = -1
    @options[:info][:score].each do |k,v|
      if v > max
        @options[:info][:winner] = k
        max = v
      end
    end
  end
end

post '/group/up/:name' do |name|
  response.headers['Access-Control-Allow-Origin'] = '*'
  record = settings.db[:groups].find(name: name).first
  # create class from db
  group = settings.groups[name]
  group.destroy if group
  group = Group.new(settings.hwsockets, record)
  if !settings.groups[name]
    settings.groups[name] = group
  else
    settings.groups[name].destroy
    settings.groups[name] = group
  end
  group.start
end

get '/control/:hwid' do |hwid|
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

  if !record['group'].nil? && !record['group'].empty?
    name = record['group']
    group = settings.groups[name]
    return if !group
  end

  request.websocket do |ws|
    ws.onopen do
      settings.swsockets[hwid] = ws
    end
    ws.onmessage do |msg|
      hwsocket = settings.manual_hwsockets[hwid]
      if hwsocket
        hwsocket.on_message(msg)
      end
    end
    ws.onclose do
      settings.swsockets.delete(hwid)
    end
  end
end

def attach_to_group socket, group_name
  record = settings.db[:games].find(name: group_name).first
  group = settings.groups[group_name]
  return nil if !group
  return DeviceWebSocketForGroup.new socket, group, group_name
end

get '/:hwid' do |hwid|
  return '' if !request.websocket?
  record = settings.db[:devices].find(hwid: hwid).first
  return '' if !record

  if record['manual']
    backend = ManualBackend.new hwid, settings.swsockets
  else
    algorithm = AlgorithmBackend.new settings.db[:algorithms]
      .find(:'algorithm-id' => record['algorithm-id']).first
    if !algorithm
      puts "Device hasn't algorithm"
      return ''
    end
    backend = AlgorithmBackend.new algorithm['algorithm']
  end

  if !record['group'].nil? && !record['group'].empty?
    group_name = record['group']
    group = settings.groups[group_name]
    backend = GroupBackend.new backend, group
  end

  socket = DeviceWebSocket.new hwid, backend, settings.manual_hwsockets

  if !record['group'].nil? && !record['group'].empty?
    socket = attach_to_group(socket, record['group'])
  end

  return if !socket

  response = socket.start request

  if record['manual']
    settings.manual_hwsockets[hwid] = socket
  end
  settings.hwsockets[hwid] = socket
  response
end

set :manual_hwsockets, {}
set :hwsockets, {}
set :swsockets, {}
set :groups, {}
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['HWSERVER_PORT']
set :bind, '0.0.0.0'
