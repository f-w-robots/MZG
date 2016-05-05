require_relative 'model'

class Device < Model
  def self.attributes
    [
      :hwid,
      :'algorithm-id',
      :icon,
    ]
  end

  def self.pluralize
    'devices'
  end
end
