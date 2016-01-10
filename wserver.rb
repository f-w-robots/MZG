require 'byebug'

require 'sinatra/base'
require 'mongo'

class Server < Sinatra::Base
  def initialize
    super
    @db = Mongo::Client.new([ 'localhost:28001' ], :database => 'mzg')
  end

  get '/' do
    @logics = @db[:logics].find
    erb :index
  end

  get '/edit/:id' do |id|
    @sha = id
    if id != 'new'
      logic = @db[:logics].find({sha: id}).first
      @logic = logic[:logic]
    end
    erb :edit
  end

  post '/edit/:id' do |id|
    if id == 'new'
      @db[:logics].insert_one(params)
      redirect "/"
    else
      logic = @db[:logics].find({sha: id}).update_one(params.merge({sha: id}))
      redirect "/edit/#{id}"
    end
  end
end

Server.run!
