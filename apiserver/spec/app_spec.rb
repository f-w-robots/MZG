require File.expand_path '../spec_helper.rb', __FILE__

describe "api" do
  it "should not allow accessing the home page" do
    get '/'
    expect(last_response.status).to be 404
  end

  describe "api - algorithm" do
    before(:each) do
      @user = User.create({'username' => 'user', 'password' => '123456', 'email' => ''})
      @algorithm = Algorithm.create({'algorithm' => 'sleep', 'user_id' => @user['_id']})
      @user.algorithms = [@algorithm]
    end

    describe "unauthorized" do
      it do
        get "/api/v1/algorithms/#{@algorithm['_id']}"
        expect(last_response.status).to be 200
      end

      it do
        get "/api/v1/algorithms/#{@algorithm['_id']}"
        expect(last_response.body).to eq '{"data":[]}'
      end

      describe "patch" do
        it do
          patch "/api/v1/algorithms/#{@algorithm['_id']}", {algorithm: 'sleep2'}
          expect(Algorithm.where('_id' => @algorithm['_id']).first['algorithm']).not_to eq 'sleep2'
        end
      end
    end

    describe "authorized" do
      before do
        allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
      end

      it do
        get "/api/v1/algorithms/#{@algorithm['_id']}"
        expect(last_response.status).to be 200
      end

      it do
        get "/api/v1/algorithms/#{@algorithm['_id']}"
        response = JSON.parse(last_response.body)
        expect(response["data"]["id"]).to eq(@algorithm['_id'].to_s)
      end

      describe "patch" do
        it do
          patch "/api/v1/algorithms/#{@algorithm['_id']}", '{"data": { "attributes": {"algorithm": "sleep2"} } }'
          expect(Algorithm.where('_id' => @algorithm['_id']).first['algorithm']).to eq 'sleep2'
        end
      end
    end
  end
end

describe "auth" do
  describe 'login/password' do
    before do
      post '/auth/signup', { 'user' => { 'username' => 'new_user', 'email' =>  'new_user@example.com', 'password' => 'password', 'password_confirmation' => 'password' } }
    end

    it "should create new user" do
      user = User.where({email: 'new_user@example.com'}).first

      expect(user).not_to be nil
    end

    it "should not create user with dublicate username" do
      count = User.count

      User.create({ username: 'new_user', password: 'password', email: '' })

      expect( User.count ).to eq count
    end
  end

  describe 'github' do
    before do
      OmniAuth.config.add_mock(:github, {"provider"=>"github", "uid"=>"995682",
        "info"=>{"nickname"=>"Neschur", "email"=>"siarheihanchuk@gmail.com", "name"=>"Sergey Ganchuk",
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

      get '/auth/github/callback', {"omniauth.auth" => OmniAuth.config.mock_auth[:github]}
    end

    it do
      expect(User.count).to eq(1)
    end

    it 'email should be present' #do
      #expect(User.first[:email]).to eq('siarheihanchuk@gmail.com')
    #end

    it 'avatar_url should be present' #do
      #expect(User.first[:avatar_url]).to eq('https://avatars.githubusercontent.com/u/995682?v=3')
    #end
  end

  describe 'profile' do
    before do
      @user = User.create({'username' => 'user', 'email' => '', 'password' => '123456'})
      allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
    end

    it 'update email' do
      patch "/api/v1/users/any", { data: {attributes: { email: 'mail@example.com'}}}.to_json
      expect(@user.reload[:email]).to eq("mail@example.com")
    end
  end

  describe 'confirmation' do
    let(:user) {User.first}

    before do
      post '/auth/signup', { 'user' => { 'email' =>  'new_user@example.com', 'password' => 'password', 'password_confirmation' => 'password' } }
    end

    it 'not confirmed' #do
      #expect(user[:confirmed]).to eq(false)
    #end

    it 'have Configuration code' #do
      #expect(user[:confirmation_code]).not_to eq(nil)
    #end

    it 'confirm' #do
      #get "/auth/confirm/#{user[:confirmation_code]}"
      #expect(user[:confirmed]).to eq(true)
    #end
  end

  describe 'forgot_password' do
    before do
      post '/auth/signup', { 'user' => { 'email' =>  'new_user@example.com', 'password' => 'password', 'password_confirmation' => 'password' } }
    end

    it 'request' #do
      #counter = Mailer.send_counter
      #post "/auth/forgot_password", {email: "user@example.com"}

    #  expect(Mailer.send_counter).to eq(counter + 1)
    #end

    it 'no user with email' #do
      #counter = Mailer.send_counter
      #post "/auth/forgot_password", {email: "user2@example.com"}

      #expect(Mailer.send_counter).to eq(counter)
    #end
  end

  describe 'models' do
    describe 'Mailer' do
      let(:mailer) { app.mailer }

      before do
        Mailer.testing_mode = true
      end

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
end
