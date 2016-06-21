describe 'models' do
  describe 'Mailer' do
    let(:mailer) { app.mailer }

    it do
      mailer.forgot_password 'user@example.com', ''
    end

    it do
      counter = Mailer.send_counter
      mailer.forgot_password 'user@example.com', ''
      expect(Mailer.send_counter).to eq(counter + 1)
    end
  end
end
