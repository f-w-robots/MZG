require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  validates_length_of :username, minimum: 3, :allow_blank => true, :allow_nil => true
  validates_length_of :password, minimum: 6
  validates_uniqueness_of :username, :allow_blank => true, :allow_nil => true
  validates_uniqueness_of :email, :allow_blank => true, :allow_nil => true

  has_many :devices
  has_many :algorithms

  def self.attributes
    [
      :username,
    ]
  end

  before_save do
    self["password"] = BCrypt::Password.create(self["password"])
  end

  before_create do
    self['email'] = '' if !self['email']
    self['confirmed'] = false

    if self['email']
      self['confirmation_code'] = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    end
  end

  def authenticate password
    BCrypt::Password.new(self["password"]) == password
  end

  index({ username: 1 }, { unique: true, name: "username_index" })
end
