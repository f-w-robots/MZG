require_relative 'model'

class Game < Model
  def self.init db
    @db = db
    @table = :games
  end

  def self.attributes
    [
      :rounds,
      :'timeout-m',
      :'timeout-s',
      :code,
      :name,
    ]
  end

  def self.pluralize
    'games'
  end
end
