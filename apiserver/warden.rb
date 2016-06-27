Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.get(id)
end

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && (params['user']['login'] || params['user']['username'] ||params['user']['email']) && params['user']['password']
  end

  def authenticate!
    user = User.where(email: params['user']['login']).first ||
    User.where(username: params['user']['login']).first ||
    User.where(email: params['user']['email']).first ||
    User.where(username: params['user']['username']).first

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
    #debugger
    if user.nil?
      attrs = slice(data)
      password = "";32.times{password << ((rand(2)==1?65:97) + rand(25)).chr}
      # debugger
      attrs.merge!({'password' => password})
      user = User.create(attrs)
    end

    success!(user)
  end

  private
  def slice data
    account_data = send("slice_#{data["provider"]}", data)
    while true
      nick_count = User.where({"username" => account_data['username']}).count
      if nick_count == 0
        break
      end
      account_data['username'] += nick_count.to_s()
    end
    account_data
  end

  def slice_github data
    {
      'providers' => {data['provider'] => data},
      'username' => data['info']['nickname'],
      'email' => data["info"]["email"] ? data["info"]["email"] : '',
      'avatar_url' => data["info"]["image"] ? data["info"]["image"] : '',
    }
  end
end
