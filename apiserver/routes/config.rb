module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          ::App::MODELS.each do |model_name|

            model = Kernel.const_get(model_name.capitalize)
            model.init ::App.db

            app.get "/api/v1/#{model.pluralize}" do
              halt "{\"data\":[]}" if !@user

              @records = @user.records(model)
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.get "/api/v1/#{model.pluralize}/:id" do |id|
              halt "{\"data\":[]}" if !@user
              @records = @user.records(model, id)
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.post "/api/v1/#{model.pluralize}" do
              halt "{\"data\":[]}" if !@user

              params = ::JSON.parse(request.body.read)
              attrs = params["data"]["attributes"]

              attrs[:user_id] = @user.record['_id']

              @records = @user.records(model, model.create(attrs).inserted_id)
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.delete "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !@user || !@user.owner?(model, id)

              model.delete id
              {meta:{}}.to_json
            end

            app.patch "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !@user || !@user.owner?(model, id)

              params = ::JSON.parse(request.body.read)
              model.update(id, params["data"]["attributes"])

              {meta:{}}.to_json
            end

            app.get '/api/v1/users/current' do
              record = @user ? @user.record : {}
              @username = record['username']
              @authorized = env['warden'].authenticate?

              erb :'api/user'
            end

            app.patch "/api/v1/users/:id" do |id|
              params = ::JSON.parse(request.body.read)["data"]["attributes"]

              user = env['warden'].user

              @errors = user.update(params)

              @username = user.record['username']
              @authorized = env['warden'].authenticate?

              erb :'api/user'
            end
          end
        end
      end
    end
  end
end
