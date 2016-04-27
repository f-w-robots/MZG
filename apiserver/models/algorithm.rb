require_relative 'model'

class Algorithm < Model
  def self.attributes
    [
      :algorithm,
      :name
    ]
  end

  def self.pluralize
    'algorithms'
  end
end
