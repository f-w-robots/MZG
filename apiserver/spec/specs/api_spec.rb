describe "api" do
  it "should not allow accessing the home page" do
    get '/'
    expect(last_response.status).to be 404
  end

  describe "user" do
    let(:response) { JSON.parse(last_response.body)["data"] }
    before(:each) do
      @user = User.create({'username' => 'user', 'password' => '123456', 'email' => 'mail@example.com'})
    end

    describe "unauthorized" do
      before do
        get "/api/v1/users/current"
      end

      it do
        expect(last_response.status).to be 200
      end

      it do
        expect(response["attributes"]["username"]).to eq("")
      end

      it do
        expect(response["attributes"]["authorized"]).to eq(false)
      end
    end

    describe "authorized" do
      before do
        allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
        get "/api/v1/users/current"
      end

      it do
        expect(last_response.status).to be 200
      end

      it do
        expect(response["attributes"]["username"]).to eq("user")
      end

      it do
        expect(response["attributes"]["authorized"]).to eq(true)
      end
    end

    describe 'update' do
      it 'username'

      describe 'email to new' do
        before do
          User.update(:confirmation_code => nil)
          allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
          patch "/api/v1/users/current", {data: { attributes: {email: "mailx@example.com"}}}.to_json
        end

        it do
          expect(User.first[:email]).to eq("mailx@example.com")
        end

        it #do
          #expect(User.first[:confirmation_code]).not_to be nil
        #end
      end

      describe 'email not updated' do
        before do
          User.update(:confirmation_code => nil)
          allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)
          patch "/api/v1/users/current", {data: { attributes: {email: "mail@example.com"}}}.to_json
        end

        it do
          expect(User.first[:email]).to eq("mail@example.com")
        end

        it #do
          #expect(User.first[:confirmation_code]).to be nil
        #end
      end

      it 'remove providers'
    end

    describe 'delete' do
      before do
        @user1 = User.create({'username' => 'user1', 'password' => '123456', 'email' => 'mail1@example.com'})
        @user2 = User.create({'username' => 'user2', 'password' => '123456', 'email' => 'mail2@example.com'})
        allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user2)

        delete '/api/v1/users/current'
      end

      it #do
        #expect(User.count).to be 1
      #end

      it #do
        #expect(User.first[:username]).to eq('user1')
      #end
    end
  end

  describe "algorithm" do
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

      it 'delete'

      it 'get all'
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

      it 'delete'

      it 'get all'
    end
  end

  it "device"
end
