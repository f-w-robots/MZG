require 'net/smtp'

class Mailer
  @@test_mode = false
  @@send_counter = 0

  def self.test_mode= test_mode
    @@test_mode = test_mode
  end

  def self.test_mode
    @@test_mode
  end

  def self.send_counter
    @@send_counter
  end

  def initialize from
    @from = from
  end

  def new_user user
    message = new_user_body(user)

    send_mail message, user['email']
  end

  def forgot_password user
    message = forgot_password_body(user)

    send_mail message, user['email']
  end

  private
  def send_mail message, to
    @@send_counter += 1
    return if @@test_mode
    Net::SMTP.start('mail') do |smtp|
      smtp.send_message message, @from, to
    end
  end

  def new_user_body user
    render_mail 'new_user', user
  end

  def forgot_password_body user
    render_mail 'forgot_password', user
  end

  def render_mail template_name, user
    template = Tilt.new("views/mails/#{template_name}.erb")
    message = template.render(user, user: user);
    base_body user['email'], message
  end

  def base_body user_mail, message
    message = <<MESSAGE_END
      From: Private Person #{@from}
      To: A Test User #{user_mail}
      MIME-Version: 1.0
      Content-type: text/html
      Subject: SMTP e-mail test

      #{message}

MESSAGE_END
  end
end
