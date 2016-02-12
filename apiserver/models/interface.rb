require_relative 'model'

class interface < Model
  def self.init db
    @db = db
    @table = :interfaces
    @idname = :id
  end
end
