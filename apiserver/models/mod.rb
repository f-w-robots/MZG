class Mod
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :user

  def self.attributes
    [
      :name
    ]
  end

  def self.relationships
    [
    ]
  end

  def self.pluralize
    'mods'
  end
end
