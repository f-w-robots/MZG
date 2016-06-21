module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          ::App::MODELS.each do |model_name|

            model = Kernel.const_get(model_name.capitalize)

            app.get "/api/v1/#{model.pluralize}" do
              halt "{\"data\":[]}" if !@user
              @records = @user.send(model.pluralize)
              @model = model

              erb :'api/models/index'
            end

            app.get "/api/v1/#{model.pluralize}/:id" do |id|
              halt "{\"data\":[]}" if !@user
              @records = @user.send(model.pluralize).where(_id: id)
              @model = model

              erb :'api/models/index'
            end

            app.post "/api/v1/#{model.pluralize}" do
              halt "{\"data\":[]}" if !@user
              params = ::JSON.parse(request.body.read)
              attrs = params["data"]["attributes"]

              @record = model.create(attrs)

              @record.user = @user
              @record.save
              @model = model
              @records = [@record]

              erb :'api/models/index'
            end

            app.delete "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !@user || @user.send(model.pluralize).where(_id: id).count < 1

              model.destroy_all(_id: id)
              {meta:{}}.to_json
            end

            app.patch "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !@user || @user.send(model.pluralize).where(_id: id).count < 1

              params = ::JSON.parse(request.body.read)

              model.where('_id' => id).update(params["data"]["attributes"])

              {meta:{}}.to_json
            end

            app.get '/api/v1/users/current' do
              @authorized = env['warden'].authenticate?
              @user ||= {}
              if env['warden'].user && env['warden'].user[:providers]
                @providers = env['warden'].user[:providers].keys
              else
                @providers = []
              end

              erb :'api/user'
            end

            app.patch "/api/v1/users/current" do
              params = ::JSON.parse(request.body.read)["data"]["attributes"]

              params.delete 'providers'
              params.delete "avatar-url"

              user = env['warden'].user
              if !params["password"]
                params.delete "password"
                params.delete "password-confirmation"
              else
                if params["password"] == params["password-confirmation"]
                  params.delete "password-confirmation"
                else
                  @errors = ['password confimation']
                end
              end

              if !@errors
                user.update(params)

                if user.errors.size > 0
                  @errors = user.errors.map{|k,e|e}
                else
                  env['warden'].authenticate!(:password)
                end
              end

              @username = user['username']
              @authorized = env['warden'].authenticate?

              erb :'api/user'
            end
          end
        end
      end
    end
  end
end
