require 'net/smtp'

class Mailer
  @@testing_mode = false
  @@send_counter = 0

  def self.testing_mode= testing_mode
    @@testing_mode = testing_mode
  end

  def self.testing_mode
    @@testing_mode
  end

  def self.send_counter
    @@send_counter
  end

  def initialize from
    @from = from
  end

  def forgot_password user_mail, restore_key
    message = forgot_password_body(user_mail, restore_key)

    @@send_counter += 1
    return if @@testing_mode
    Net::SMTP.start('mail') do |smtp|
      smtp.send_message message, @from, user_mail
    end
  end

  private
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
