require_relative 'model'

class User
  def self.init(db)
    @@db = db
  end

  def initialize session_id
    @session_id = session_id

    session = @@db[:sessions].find(:session_id => @session_id).first
    if session
      @user = @@db[:users].find(_id: session[:user_id]).first
    end
  end

  def self.login data, session_id
    return false if !session_id
    session_id = session_id
    params = {'provider' => data['provider'], 'uid' => data['uid']}
    user = @@db[:users].find(params).first
    if !user
      user_id = @@db[:users].insert_one(params).inserted_id
      user = @@db[:users].find({'_id' => user_id}).first
    end

    @@db[:sessions].find(:session_id => session_id).find_one_and_delete
    @@db[:sessions].insert_one({session_id: session_id, user_id: user["_id"]})

    user
  end

  def records model, id = nil
    records = []
    return records if !@user

    (id ? model.get(id) : model.all).each do |record|
      if record["user_id"] == @user["_id"]
        records.push record
      end
    end

    records
  end

  def record
    @user
  end

  def access? model, id
    allow = true
    model.get(id).each do |record|
      if record["user_id"] != @user["_id"]
        allow = false
      end
    end

    allow
  end

  def authorized?
    !!@user
  end
end
