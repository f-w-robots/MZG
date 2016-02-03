class Device
  def self.init db
    @@db = db
  end

  def self.all
    @@db[:devices].find()
  end

  def self.create params
    @@db[:devices].insert_one(params)
  end

  def self.get hwid
    @@db[:devices].find({hwid: hwid}).first.to_json
  end

  def self.delete hwid
    @@db[:devices].find({hwid: hwid}).delete_one
  end

  def self.update hwid, params
    @@db[:devices].find({hwid: hwid}).update_one(params)
  end
end
