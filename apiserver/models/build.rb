class Build
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :device
  belongs_to :user

  def self.attributes
    [
      :name
    ]
  end

  def self.relationships
    [
      :components
    ]
  end

  def self.pluralize
    'builds'
  end
end
