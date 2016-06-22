describe 'models' do
  describe 'Mailer' do
    let(:mailer) { app.mailer }

    before do
      User.create(username: 'username', email: 'mail@example.com', password: 'password')
    end

    it do
      mailer.forgot_password User.first
    end

    it do
      counter = Mailer.send_counter
      mailer.forgot_password User.first
      expect(Mailer.send_counter).to eq(counter + 1)
    end

    it do
      mailer.send(:new_user_body, User.first)
    end
  end
end
