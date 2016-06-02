class Device
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :user
  has_one :algorithms

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
