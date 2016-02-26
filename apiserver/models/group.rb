require_relative 'model'

class Group < Model
  def self.init db
    @db = db
    @table = :groups
  end

  def self.attributes
    [
      :options,
      :code,
      :name,
    ]
  end

  def self.pluralize
    'groups'
  end
end
