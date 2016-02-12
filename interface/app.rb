# Server for web interface
#
# Show connected devices and
# manage algorithms
#
require 'byebug'

require 'sinatra'
require 'mongo'

get '/' do
  @records = settings.db[:devices].find
  erb :index
end

get '/edit/:id' do |id|
  @hwid = id
  if id != 'new'
    record = settings.db[:devices].find({hwid: id}).first
    @algorithm = record[:algorithm]
    @interface = record[:interface].gsub('<', '&lt')
    @manual = record[:manual]
  end
  erb :edit
end

post '/edit/:id' do |id|
  record = {}
  record['algorithm'] = params['algorithm']
  record['interface'] = params['interface']
  params['useManual'] == 'on' ? record['manual'] = true : record['manual'] = false
  if id == 'new'
    record['hwid'] = params['hwid']
    if record['hwid'] == ''
      record['hwid'] = rand.to_s[2..-1]
    end
    settings.db[:devices].insert_one(record)
    redirect "/"
  else
    settings.db[:devices].find({hwid: id}).update_one(record.merge!({hwid: id}))
    redirect "/edit/#{record[:hwid]}"
  end
end

get '/delete/:id' do |id|
  settings.db[:devices].find({hwid: id}).delete_one
  redirect '/'
end

get '/delete/' do
  settings.db[:devices].find({hwid: nil}).delete_many
  redirect '/'
end

set :db, Mongo::Client.new([ "#{ENV['DB_HOST']}:#{ENV['DB_PORT']}" ], :database => ENV['DB_NAME'])
set :port, ENV['WEB_PORT']
set :bind, "0.0.0.0"
