# Server for web interface
#
# Show connected devices and
# manage algorithms
#
require 'byebug'

require 'sinatra'
require 'mongo'
require 'net/http'

CONFIG = YAML.load_file("config.yml")

get '/' do
  @logics = settings.db[:logics].find
  erb :index
end

get '/edit/:id' do |id|
  @sha = id
  if id != 'new'
    logic = settings.db[:logics].find({sha: id}).first
    @logic = logic[:logic]
  end
  erb :edit
end

post '/edit/:id' do |id|
  if id == 'new'
    settings.db[:logics].insert_one(params)
    redirect "/"
  else
    logic = settings.db[:logics].find({sha: id}).update_one(params.merge({sha: id}))
    redirect "/edit/#{id}"
  end
end

set :port, CONFIG['wserver']['port']
set :db, Mongo::Client.new([ "#{CONFIG['database']['host']}:#{CONFIG['database']['port']}" ],
  :database => CONFIG['database']['dbname'])
