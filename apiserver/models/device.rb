require_relative 'model'

class Device < Model
  def self.init db
    @db = db
    @table = :devices
    @idname = :hwid
  end

  def self.attributes
    [
      :manual,
      :hwid,
      :'algorithm-id',
      :'interface-id'
    ]
  end
end
