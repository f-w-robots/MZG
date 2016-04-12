require_relative 'model'

class Group < Model
  def self.attributes
    [
      :options,
      :code,
      :name,
      :fields,
    ]
  end

  def self.pluralize
    'groups'
  end
end
