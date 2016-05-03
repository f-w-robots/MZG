require File.dirname(__FILE__) + '/app'

use Rack::Session::Cookie, :secret => ENV['secret']

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.get(id)
end

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && params['user']['username'] && params['user']['password']
  end

  def authenticate!
    user = User.first(username: params['user']['username'])

    if user.nil?
      throw(:warden, message: "The username you entered does not exist.")
    elsif user.authenticate(params['user']['password'])
      success!(user)
    else
      throw(:warden, message: "The username and password combination ")
    end
  end
end

Warden::Strategies.add(:vkontakte) do
  def valid?
    data = env['omniauth.auth'].to_hash
    data['provider'] == 'vkontakte' && !data['uid'].empty?
  end

  def authenticate!
    data = env['omniauth.auth'].to_hash
    user = User.first({"providers.#{data['provider']}.uid" => data['uid']})

    if user.nil?
      user = User.create({providers: {data['provider'] => data}, username: data['provider'] + '-' + data['uid']})
      success!(user)
    else
      success!(user)
    end
  end
end

App.run!
