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

  def new_user user_mail, confirmation_code
    message = new_user_body(user_mail, confirmation_code)

    send_mail message, user_mail
  end

  def forgot_password user_mail, restore_key
    message = forgot_password_body(user_mail, restore_key)

    send_mail message, user_mail
  end

  private
  def send_mail message, to
    @@send_counter += 1
    return if @@test_mode
    Net::SMTP.start('mail') do |smtp|
      smtp.send_message message, @from, to
    end
  end

  def new_user_body user_mail, confirmation_code
    base_body(user_mail, "new_user, confirm code: #{confirmation_code}")
  end

  def forgot_password_body user_mail, restore_key
    base_body(user_mail, "forgot, key: #{restore_key}")
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
