describe "auth" do
  describe 'sign up' do
    before do
      post '/auth/signup', { 'user' => { 'email' =>  'new_user@example.com', 'password' => 'password', 'password_confirmation' => 'password' } }
      User.all.update(username: 'username')
    end

    it "should create new user" do
      user = User.where({email: 'new_user@example.com'}).first

      expect(user).not_to be nil
    end

    it "should not create user with dublicate username" do
      count = User.count

      User.create({ username: 'username', password: 'password', email: '' })

      expect( User.count ).to eq count
    end

    it "should create new user" do
      user = User.where({email: 'new_user@example.com'}).first
      password = user['password']
      user['username'] = user['username'] + 'add'
      user.save!

      expect(user.reload['password']).to eq(password)
    end

    it 'signin after signup' do
      expect(last_request.env['warden'].user).not_to be nil
    end
  end

  describe 'sign in' do
    describe 'success' do
      before do
        User.create('username' => 'username', 'email' =>  'new_user@example.com', 'password' => 'password', 'password_confirmation' => 'password')
      end

      it "login by email" do
        post '/auth/signin', { 'user' => { 'login' =>  'new_user@example.com', 'password' => 'password' } }

        expect(last_request.env['warden'].user).not_to be nil
      end

      it "login by name" do
        post '/auth/signin', { 'user' => { 'login' =>  'username', 'password' => 'password' } }

        expect(last_request.env['warden'].user).not_to be nil
      end
    end

    describe 'unsuccess' do
      before do
        User.create('username' => 'username', 'email' =>  '', 'password' => 'password', 'password_confirmation' => 'password')
      end

      # check if user create
      it do
        expect(User.count).to eq(1)
      end

      it "login by email" #do
        #post '/auth/signin', { 'user' => { 'email' =>  '', 'password' => 'password' } }

        #expect(last_request.env['warden'].user).to be nil
      #end

      # enable it if allow empty usernames
      # it "login by name" #do
      #   #post '/auth/signin', { 'user' => { 'email' =>  '', 'password' => 'password' } }
      #
      #   #expect(last_request.env['warden'].user).to be nil
      # #end
    end
  end

  describe 'github' do
    before do
      OmniAuth.config.add_mock(:github, {"provider"=>"github", "uid"=>"995682",
        "info"=>{"nickname"=>"Neschur", "email"=>"email_from_github@gmail.com", "name"=>"Sergey Ganchuk",
          "image"=>"https://avatars.githubusercontent.com/u/995682?v=3", "urls"=>{"GitHub"=>"https://github.com/Neschur", "Blog"=>nil}},
        "credentials"=>{"token"=>"wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww", "expires"=>false},
        "extra"=>{"raw_info"=>{"login"=>"Neschur", "id"=>995682, "avatar_url"=>"https://avatars.githubusercontent.com/u/995682?v=3",
          "gravatar_id"=>"", "url"=>"https://api.github.com/users/Neschur", "html_url"=>"https://github.com/Neschur",
          "followers_url"=>"https://api.github.com/users/Neschur/followers", "following_url"=>"https://api.github.com/users/Neschur/following{/other_user}",
          "gists_url"=>"https://api.github.com/users/Neschur/gists{/gist_id}", "starred_url"=>"https://api.github.com/users/Neschur/starred{/owner}{/repo}",
          "subscriptions_url"=>"https://api.github.com/users/Neschur/subscriptions", "organizations_url"=>"https://api.github.com/users/Neschur/orgs",
          "repos_url"=>"https://api.github.com/users/Neschur/repos", "events_url"=>"https://api.github.com/users/Neschur/events{/privacy}",
          "received_events_url"=>"https://api.github.com/users/Neschur/received_events", "type"=>"User", "site_admin"=>false, "name"=>"Sergey Ganchuk",
          "company"=>nil, "blog"=>nil, "location"=>"Minsk, Belarus", "email"=>nil, "hireable"=>nil, "bio"=>nil, "public_repos"=>31, "public_gists"=>0,
          "followers"=>2, "following"=>3, "created_at"=>"2011-08-22T07:46:32Z", "updated_at"=>"2016-06-19T12:34:23Z", "private_gists"=>0, "total_private_repos"=>0,
          "owned_private_repos"=>0, "disk_usage"=>6904, "collaborators"=>0, "plan"=>{"name"=>"free", "space"=>976562499, "collaborators"=>0, "private_repos"=>0}}}
        })
    end

    describe do
      it do
        @user = User.create({'username' => 'Neschur', 'password' => '123456', 'email' => 'afewff@gmail.com'})
        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
        expect(User.where({email: 'email_from_github@gmail.com'}).first[:username]).to eq('Neschur1')
      end

      it do
        @user1 = User.create({'username' => 'Neschur', 'password' => '123456', 'email' => 'afewff@gmail.com'})
        @user2 = User.create({'username' => 'Neschur1', 'password' => '123456', 'email' => 'ddqwff@gmail.com'})
        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
        expect(User.where({email: 'email_from_github@gmail.com'}).first[:username]).to eq('Neschur11')
      end
    end

    describe do
      before do
        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
      end

      it do
        expect(User.count).to eq(1)
      end

      it 'email should be present' do
        expect(User.first[:email]).to eq('email_from_github@gmail.com')
      end

      it 'github nickname' do
        expect(User.first[:username]).to eq('Neschur')
      end

      it do
        get '/auth/logout'
        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
        expect(last_request.env['warden'].user).not_to be nil
      end

      it 'avatar_url should be present' do
        expect(User.first[:avatar_url]).to eq('https://avatars.githubusercontent.com/u/995682?v=3')
      end
    end

    describe 'email in use' do
      before do
        User.create({'username' => 'user', 'password' => '123456', 'email' => 'email_from_github@gmail.com'})
      end

      it #do
        #count = User.count
        #get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
        #expect(User.count).to be count
      #end
    end

    describe 'connect' do
      before do
        @user = User.create({'username' => 'user', 'password' => '123456', 'email' => 'mail@example.com'})
        allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
        @count = User.count

        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
      end

      it 'no errors' do
        # nothing
      end

      it 'not create new user' do
        expect(User.count).to eq(@count)
      end

      it 'add provider for current user' do
        expect(User.first.reload[:providers]).not_to be_empty
      end
    end

    describe 'disallow connect if user exists' do
      before do
        User.create({'username' => 'user22', 'password' => '123456', 'email' => 'mail22@example.com',
          'providers' => {'github' => {'provider' => 'github', 'uid' => '995682'}}
          })
        @user = User.create({'username' => 'user', 'password' => '123456', 'email' => 'mail@example.com'})
        allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
        @count = User.count

        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
      end

      it 'not create new user' do
        expect(User.count).to eq(@count)
      end

      it 'not add provider for current user' do
        expect(@user.reload[:providers]).to be nil
      end
    end

    describe 'login if email exists' do
      before do
        @user = User.create({'username' => 'user', 'password' => '123456', 'email' => 'email_from_github@gmail.com'})
        @count = User.count

        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
      end

      it 'not create new user' do
        expect(User.count).to eq(@count)
      end

      it 'login' do
        expect(last_request.env['warden'].user).not_to be nil
      end

      it 'add provider for current user' do
        expect(@user.reload[:providers]).not_to be nil
      end

      it 'confirm current user' do
        expect(@user.reload[:confirmed]).to be true
      end
    end

    describe 'login if email and github exists' do
      before do
        @user = User.create({'username' => 'user', 'password' => '123456', 'email' => 'email_from_github@gmail.com',
          'providers' => {'github' => {'provider' => 'github', 'uid' => '144'}}
        })
        @count = User.count

        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
      end

      it 'not create new user' do
        expect(User.count).to eq(@count)
      end

      it 'not login' do
        expect(last_request.env['warden'].user).to be nil
      end

      it 'not rewrite provider for current user' do
        expect(@user.reload[:providers]['github']['uid']).to eq("144")
      end

      it 'redirect' do
        expect(last_response.location).to include('/?error=')
        # 1
      end
    end

    describe 'disconnect' do
      before do
        get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
      end

      it do
        expect(User.first[:providers]).not_to be_empty
      end

      it do
        get '/auth/github/disconnect'

        expect(User.first.reload[:providers]).to be_empty
      end
    end
  end

  describe 'profile' do
    before do
      @user = User.create({'username' => 'user', 'email' => '', 'password' => '123456'})
      allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
    end

    it 'update email' do
      patch "/api/v1/users/current", { data: {attributes: { email: 'mail@example.com'}}}.to_json
      expect(@user.reload[:email]).to eq("mail@example.com")
    end
  end

  describe 'confirmation' do
    let(:user) {User.first}

    before do
      @send_counter = Mailer.send_counter
      post '/auth/signup', { 'user' => { 'email' =>  'new_user@example.com', 'password' => 'password', 'password_confirmation' => 'password' } }
    end

    it 'not confirmed' do
      expect(user[:confirmed]).to eq(false)
    end

    it 'have Configuration code' do
      expect(user[:confirmation_code]).not_to eq(nil)
    end

    it 'confirm' do
      get "/auth/confirm/#{user[:confirmation_code]}"

      expect(user.reload[:confirmed]).to eq(true)
    end

    it 'send email' do
      expect(Mailer.send_counter).to eq(@send_counter + 1)
    end
  end

  describe 'forgot_password' do
    before do
      post '/auth/signup', { 'user' => { 'email' =>  'user@example.com', 'password' => 'password', 'password_confirmation' => 'password' } }
    end

    it do
      expect(User.first[:forgot_password_code]).to be nil
    end

    it 'no user with email' do
      counter = Mailer.send_counter
      post "/auth/forgot_password", {email: "user2@example.com"}

      expect(Mailer.send_counter).to eq(counter)
    end

    describe do
      before do
        @counter = Mailer.send_counter
        post "/auth/forgot_password", {email: "user@example.com"}
      end

      it do
        expect(User.first[:forgot_password_code]).not_to be nil
      end

      it 'request' do
        expect(Mailer.send_counter).to eq(@counter + 1)
      end

      it 'update password' do
        post "/auth/update_password", {password: 'password', password_confirmation: 'password', key: User.first[:forgot_password_code]}

        expect(last_response.status).to eq(201)
      end

      it 'update password' do
        post "/auth/update_password", {password: '22222222', password_confirmation: 'password', key: User.first[:forgot_password_code]}

        expect(last_response.status).to eq(200)
      end

      it 'update password' do
        post "/auth/update_password", {password: 'password', password_confirmation: 'password', key: User.first[:forgot_password_code] + 'www'}

        expect(last_response.status).to eq(200)
      end

      it 'set forgot_password key' do
        expect(User.first[:forgot_password_code]).not_to eq(nil)
      end

      it 'forgot_password key length' do
        expect(User.first[:forgot_password_code].length).to be > 100
      end

      it 'unset forgot_password key' do
        post "/auth/update_password", {password: 'password', password_confirmation: 'password', key: User.first[:forgot_password_code]}

        expect(User.first[:forgot_password_code]).to eq(nil)
      end
    end
  end
end
