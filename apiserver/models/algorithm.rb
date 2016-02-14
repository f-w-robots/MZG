require_relative 'model'

class Algorithm < Model
  def self.init db
    @db = db
    @table = :algorithms
  end

  def self.attributes
    [
      :'algorithm-id',
      :algorithm,
    ]
  end

  def self.pluralize
    'algorithms'
  end
end
