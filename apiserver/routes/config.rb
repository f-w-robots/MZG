module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          ::App::MODELS.each do |model_name|

            model = Kernel.const_get(model_name.capitalize)
            model.init ::App.db

            app.get "/api/v1/#{model.pluralize}" do
              if !User.access?(request.cookies["rack.session"])
                @records = []
              else
                @records = model.all
                @attributes = model.attributes
                @model = model
              end

              erb :'api/models/index'
            end

            app.get "/api/v1/#{model.pluralize}/:id" do |id|
              if !User.access?(request.cookies["rack.session"])
                @records = []
              else
                @records = model.get id
                @attributes = model.attributes
                @model = model
              end

              erb :'api/models/index'
            end

            app.post "/api/v1/#{model.pluralize}" do
              return 403 if !User.access?(request.cookies["rack.session"])

              params = JSON.parse(request.body.read)
              attrs = params["data"]["attributes"]

              model.create(attrs)
              status 201
              {meta:{}}.to_json
            end

            app.delete "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !User.access?(request.cookies["rack.session"])
              model.delete id
              {meta:{}}.to_json
            end

            app.patch "/api/v1/#{model.pluralize}/:id" do |id|
              return 403 if !User.access?(request.cookies["rack.session"])
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
