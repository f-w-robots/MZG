class User
  include BCrypt
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  validates_length_of :username, minimum: 3, :allow_blank => true, :allow_nil => true
  validates_format_of :username, :with => /\A(^[a-z][a-z0-9]*([._-][a-z0-9]+){0,3}$)\Z/i, :allow_blank => true
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

  def self.relationships
    [
    ]
  end

  before_create do
    self['email'] = '' if !self['email']
    self['confirmed'] = false

    @device = Device.create("hwid" => "Device" + rand(10000000).to_s)
    @device.user = self
    @device.save

    if self['email']
      self['confirmation_code'] = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    end
  end

  def authenticate password
    Password.new(self["password"]) == password
  end

  def password
    Password.new(self['password'])
  end

  def password=(password)
    self['password'] = Password.create(password)
    @unencrypted_pass = password
  end

  def get_unencrypt_pass
    @unencrypted_pass
  end

  def add_provider! provider, data
    providers = self['providers'] || {}
    self['providers'] = nil
    self.save
    providers[provider] = data
    self['providers'] = providers
    self.save
  end

  index({ username: 1 }, { unique: true, name: "username_index" })
end
