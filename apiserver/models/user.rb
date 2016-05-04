require_relative 'model'
require 'bcrypt'

class User
  def self.init(db)
    @@db = db
    @@table = :users
  end

  def self.validate param, value
    if param.to_sym == :password
      if value && value.size > 5
        return true
      else
        return false
      end
    end
  end

  def initialize params
    @params = params
  end

  def id
    @params['_id'].to_s
  end

  def authenticate password
    BCrypt::Password.new(@params[:password]) == password
  end

  def records model, id = nil
    return [] if(model.is_a?(User))
    records = []
    return records if !@params

    (id ? model.get(id) : model.all).each do |record|
      if record["user_id"] == @params["_id"]
        records.push record
      end
    end

    records
  end

  def record
    @params
  end

  def self.get id
    first({'_id' => BSON::ObjectId(id)})
  end

  def self.create(params)
    if User.validate(:password, params['password'])
      params['password'] = BCrypt::Password.create(params['password'])
      get(@@db[@@table].insert_one(params).inserted_id)
    end
  end

  def self.first params
    data = @@db[@@table].find(params).first
    if data
      User.new(data)
    end
  end

  def self.attributes
    [
      :username,
    ]
  end

  def self.pluralize
    'users'
  end

  def update params
    errors = []
    @@db['users'].update_one({'_id' => @params['_id']}, {"$set" => {"username" => params['username']}})
    if params['password']
      if params['password-confirmation'] == params['password']
        if User.validate(:password, params['password'])
          params['password'] = BCrypt::Password.create(params['password'])
          @@db['users'].update_one({'_id' => @params['_id']}, {"$set" => {"password" => params['password']}})
        else
          errors = [:err2]
        end
      else
        errors = [:err1]
      end
    end
  end

  def owner? model, id
    allow = true
    model.get(id).each do |record|
      if record["user_id"] != @params["_id"]
        allow = false
      end
    end

    allow
  end
end
