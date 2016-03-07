require_relative 'model'

class Device < Model
  def self.init db
    @db = db
    @table = :devices
  end

  def self.attributes
    [
      :manual,
      :hwid,
      :'algorithm-id',
      :'interface-id',
      :icon,
      :group,
      :'use-proxy',
      :'proxy-id',
    ]
  end

  def self.pluralize
    'devices'
  end
end
