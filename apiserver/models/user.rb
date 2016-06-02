require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  has_many :devices
  has_many :algorithms

  def self.attributes
    [
      :username,
    ]
  end

  def self.pluralize
    'users'
  end

  before_save do
    self["password"] = BCrypt::Password.create(self["password"])
  end

  def authenticate password
    BCrypt::Password.new(self["password"]) == password
  end
end
