class Model
  def self.all
    @db[@table].find()
  end

  def self.create params
    @db[@table].insert_one(params)
  end

  def self.get id
    @db[@table].find({@idname => id})
  end

  def self.delete id
    @db[@table].find({@idname => id}).delete_one
  end

  def self.update id, params
    @db[@table].find({@idname => id}).update_one(params)
  end
end
