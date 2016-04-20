require_relative 'model'

class User
  def self.init(db)
    @db = db
  end

  def self.login data, session_id
    return false if !session_id
    session_id = session_id[10..125]#TODO!!!
    params = {'provider' => data['provider'], 'uid' => data['uid']}
    user = @db[:users].find(params).first
    if !user
      user = @db[:users].insert_one(params)
    end

    @db[:sessions].find(:session_id => session_id).find_one_and_delete
    @db[:sessions].insert_one({session_id: session_id, user_id: user["_id"]})
  end

  def self.access? session_id
    return false if !session_id
    session_id = session_id[10..125]#TODO!!!
    session = @db[:sessions].find({session_id: session_id}).first
    return false if !session

    user = @db[:sessions].find({_id: session['user_id']})
  end
end
