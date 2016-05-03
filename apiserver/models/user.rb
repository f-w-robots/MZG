require_relative 'model'

class User
  def self.init(db)
    @@db = db
    @@table = :users
  end

  def initialize params
    @params = params
  end

  def id
    @params['_id'].to_s
  end

  def self.first params
    data = @@db[@@table].find(params).first
    if data
      User.new(data)
    end
  end

  def authenticate password
    @params[:password] == password
  end

  def self.get id
    first({'_id' => BSON::ObjectId(id)})

  end

  def self.create(params)
    get(@@db[@@table].insert_one(params).inserted_id)
  end

  def records model, id = nil
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
end
