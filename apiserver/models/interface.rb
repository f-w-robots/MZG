require_relative 'model'

class Interface < Model
  def self.init(db)
    super(db)
    @idname = :id
  end

  def self.attributes
    [
      :'interface-id',
      :interface,
    ]
  end

  def self.pluralize
    'interfaces'
  end
end
