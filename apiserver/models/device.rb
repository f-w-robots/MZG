require_relative 'model'

class Device < Model
  def self.init db
    @db = db
    @table = :devices
    @idname = :hwid
  end
end
