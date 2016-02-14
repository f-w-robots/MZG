class Model
  def self.all
    @db[@table].find()
  end

  def self.create params
    @db[@table].insert_one(params)
  end

  def self.get id
    @db[@table].find({'_id' => BSON::ObjectId(id)})
  end

  def self.delete id
    @db[@table].find({'_id' => BSON::ObjectId(id)}).delete_one
  end

  def self.delete_all
    @db[@table].find({}).delete_many
  end

  def self.update id, params
    @db[@table].find({'_id' => BSON::ObjectId(id)}).update_one(params)
  end
end
