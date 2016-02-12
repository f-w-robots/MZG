require_relative 'model'

class Algorithm < Model
  def self.init db
    @db = db
    @table = :algorithms
    @idname = :id
  end
end
