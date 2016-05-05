# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

describe "api" do
  it "should not allow accessing the home page" do
    get '/'
    expect(last_response.status).to be 404
  end

  describe "api - algorithm" do
    before(:all) do
      @user = User.create({'username' => 'user', 'password' => '123456'})
      @algorithm = Algorithm.create({'algorithm' => 'sleep', 'user_id' => @user.record['_id']}).first
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
    end

    describe "unauthorized" do
      it do
        get "/api/v1/algorithms/#{@algorithm['_id']}"
        expect(last_response.status).to be 200
      end

      it do
        allow_any_instance_of(Warden::Proxy).to receive_messages(:user => @user)

        get "/api/v1/algorithms/#{@algorithm['_id']}"
        response = JSON.parse(last_response.body)
        expect(response["data"]["id"]).to eq(@algorithm['_id'].to_s)
      end
    end
  end
end

describe "auth" do
  it "should create new user" do
    post '/auth/signup', { user: { username: 'new_user', password: 'password', password_confimation: 'password' } }
    user = User.first({username: 'new_user'})

    expect(last_response.status).not_to be nil
  end

  it "should not create user with dublicate username" do
    User.create({ username: 'new_user', password: 'password', password_confimation: 'password' })

    expect{ post '/auth/signup', { user: { username: 'new_user', password: 'password', password_confimation: 'password' } } }.to raise_error(Mongo::Error::OperationFailure)
  end
end
