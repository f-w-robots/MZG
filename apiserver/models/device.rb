class Device
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :user
  has_one :algorithms
  validates_uniqueness_of :hwid

  def self.attributes
    [
      :hwid,
      :'algorithm-id',
      :icon,
    ]
  end

  def self.relationships
    [
      :'device-build',
    ]
  end

  def self.pluralize
    'devices'
  end

  index({ hwid: 1 }, { unique: true, name: "hwid_index" })
end
