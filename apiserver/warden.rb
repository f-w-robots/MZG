Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.get(id)
end

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && params['user']['email'] && params['user']['password']
  end

  def authenticate!
    user = User.where(username: params['user']['email']).first

    if user.nil?
      throw(:warden, message: "The username you entered does not exist.")
    elsif user.authenticate(params['user']['password'])
      success!(user)
    else
      throw(:warden, message: "The username and password combination ")
    end
  end
end

Warden::Strategies.add(:omniauth) do
  def valid?
    data = env['omniauth.auth'].to_hash
    !data['provider'].empty? && !data['uid'].empty?
  end
  def authenticate!
    data = env['omniauth.auth'].to_hash
    user = User.where({"providers.#{data['provider']}.uid" => data['uid']}).first
    if user.nil?
      password = ""
      32.times{password << ((rand(2)==1?65:97) + rand(25)).chr}
      user = User.create({
        'providers' => {data['provider'] => data},
        'username' => data['provider'] + '-' + data['uid'],
        'password' => password,
        'email' => '',
      })
      success!(user)
    else
      success!(user)
    end
  end
end
