class Algorithm
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :device
  belongs_to :user

  def self.attributes
    [
      :algorithm,
      :name
    ]
  end

  def self.relationships
    [
    ]
  end

  def self.pluralize
    'algorithms'
  end
end
