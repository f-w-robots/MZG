require 'net/smtp'
require 'mail'

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
      smtp.send_message message.to_s, @from, to
    end
  end

  def new_user_body user
    render_mail 'new_user', user, 'Welcome to ROBATZ'
  end

  def forgot_password_body user
    render_mail 'forgot_password', user, 'Password forgotten'
  end

  def render_mail template_name, user, subject
    template = Tilt.new("views/mails/#{template_name}.erb")
    message = template.render(user, user: user);
    base_body user, message, subject
  end

  def base_body user, message, subject
    mail = Mail.new do
      from    @from
      to      user['email']
      subject subject
      content_type 'text/html; charset=UTF-8'
      body message
    end
    mail['from'] = @from
    mail
  end
end
