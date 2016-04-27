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

              success = model.create(attrs)
              if success
                status 201
              else
                status 500
              end
              {meta:{}}.to_json
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
              content_type 'text/plain'
              app.set :user, User.login(request.env['omniauth.auth'].to_hash, request.cookies["rack.session"])
              redirect ENV['AUTH_REDIRECT']
            end
          end
        end
      end
    end
  end
end
