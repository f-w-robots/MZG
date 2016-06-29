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

  describe "Models" do

    it 'not allow @ sign' do
      User.create(username: 'usern@me', email: 'mail@example.com', password: 'password')
      expect(User.first).to be_nil
    end

    it 'user is save' do
      User.create(username: 'username', email: 'mail@example.com', password: 'password')
      expect(User.first).not_to be_nil
    end
  end
end
