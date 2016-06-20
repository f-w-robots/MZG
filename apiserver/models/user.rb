require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  validates_length_of :username, minimum: 3
  validates_length_of :password, minimum: 6
  validates_uniqueness_of :username
  validates_uniqueness_of :email

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

  index({ username: 1 }, { unique: true, name: "username_index" })
end
