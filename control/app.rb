require 'sinatra'
require 'mongo'

get '/:id' do |id|
  record = settings.db[:devices].find({hwid: id}).first
  @iframe = record[:interface]
  if(@iframe.start_with?('file:'))
    @iframe = open(@iframe.gsub('file:','').strip).read
  end
  @deviceId = id
  erb :iframe
end

set :protection, except: [:frame_options]
set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['CONTROL_PORT']
set :bind, "0.0.0.0"
