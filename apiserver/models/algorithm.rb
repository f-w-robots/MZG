require_relative 'model'

class Algorithm < Model
  def self.init db
    @db = db
    @table = :algorithms
    @idname = :id
  end

  def self.attributes
    [
      :id,
      :algorithm,
    ]
  end

  def self.pluralize
    'algorithms'
  end
end
