# Server for devices
#
# Accepts connections from devices by web-sockets
# and control devices through the connections
#
require 'byebug'
Thread::abort_on_exception = true

require 'json'
require 'sinatra/base'
require 'sinatra-websocket'
require 'mongo'

require_relative 'bricks/bricks.rb'
require_relative 'bricks/brick.rb'
require_relative 'bricks/group.rb'
require_relative 'bricks/proxy.rb'
require_relative 'bricks/control.rb'
require_relative 'bricks/algorithm.rb'
require_relative 'bricks/device.rb'

require_relative 'db/db.rb'
require_relative 'db/device.rb'
require_relative 'db/group.rb'

require_relative 'group_interface.rb'
require_relative 'device_manager.rb'
require_relative 'logger.rb'

$LOAD_PATH.push File.expand_path('../routes', __FILE__)
%w{ config }.each { |file| require file }

class App < Sinatra::Base
  register Sinatra::App::Routing::Config

  set :devices, {}
  set :groups, {}

  set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
  set :port, ENV['HWSERVER_PORT']
  set :bind, '0.0.0.0'

  set :device_manager, DeviceManager.new
  Mongo::Logger.logger.level = ::Logger::FATAL
end
