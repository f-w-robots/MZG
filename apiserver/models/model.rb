class Model
  def self.init(db)
    @db = db
    @table = pluralize.to_sym
  end

  def self.all
    @db[@table].find()
  end

  def self.create(params)
    self.get(@db[@table].insert_one(params).inserted_id)
  end

  def self.first params
    @db[@table].find(params).first
  end

  def self.find params
    @db[@table].find(params)
  end

  def self.get(id)
    @db[@table].find({'_id' => BSON::ObjectId(id)})
  end

  def self.delete(id)
    @db[@table].find({'_id' => BSON::ObjectId(id)}).delete_one
  end

  def self.delete_all
    @db[@table].find({}).delete_many
  end

  def self.update(id, params)
    @db[@table].find({'_id' => BSON::ObjectId(id)}).update_one({ '$set' => params})
  end
end
