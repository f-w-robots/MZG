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
require 'docker'
require 'socket'
require 'rb-inotify'

require_relative 'models/device.rb'
require_relative 'models/device_record.rb'
require_relative 'models/device.rb'
require_relative 'models/logger.rb'
require_relative 'models/manager.rb'
require_relative 'models/mailer.rb'
require_relative 'models/unix_connection.rb'

$LOAD_PATH.push File.expand_path('../routes', __FILE__)
%w{ config }.each { |file| require file }

class App < Sinatra::Base
  Docker.version
  register Sinatra::App::Routing::Config

  set :devices, {}
  set :groups, {}

  set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
  set :port, ENV['HWSERVER_PORT']
  set :bind, '0.0.0.0'

  set :manager, Manager.new
  Mongo::Logger.logger.level = ::Logger::FATAL
end
