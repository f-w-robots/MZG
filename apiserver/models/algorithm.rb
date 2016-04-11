require_relative 'model'

class Algorithm < Model
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
