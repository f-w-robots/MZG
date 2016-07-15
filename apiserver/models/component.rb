class Component
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :user

  def self.attributes
    [
      :name,
      :mods,
    ]
  end

  def self.relationships
    [
    ]
  end

  def self.pluralize
    'components'
  end
end
