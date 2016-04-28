module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          ::App::MODELS.each do |model_name|

            model = Kernel.const_get(model_name.capitalize)
            model.init ::App.db

            app.get "/api/v1/#{model.pluralize}" do
              @records = @user.records(model)
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.get "/api/v1/#{model.pluralize}/:id" do |id|
              @records = @user.records(model, id)
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.post "/api/v1/#{model.pluralize}" do
              params = JSON.parse(request.body.read)
              attrs = params["data"]["attributes"]

              attrs[:user_id] = @user.record['_id']

              r = model.create(attrs)
              @records = @user.records(model, r.inserted_id)
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.delete "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !@user.access?(model, id)

              model.delete id
              {meta:{}}.to_json
            end

            app.patch "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !@user.access?(model, id)

              params = JSON.parse(request.body.read)
              model.update(id, params["data"]["attributes"])

              {meta:{}}.to_json
            end

            app.get '/auth/:provider/callback' do |provider|
              app.set :user, User.login(request.env['omniauth.auth'].to_hash, cookies[:session_id])
              redirect ENV['AUTH_REDIRECT']
            end

            app.get '/auth/logout' do
              user = User.new(cookies[:session_id])
              user.logout
              redirect ENV['AUTH_REDIRECT']
            end

            app.get '/api/v1/users/current' do
              '{"data":
                  {
                    "type": "users",
                    "id": "current",
                    "attributes": {
                        "authorized": ' + @user.authorized?.to_s + '
                    }
                  }
                }'
            end
          end
        end
      end
    end
  end
end
