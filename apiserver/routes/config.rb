module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          ::App::MODELS.each do |model_name|

            model = Kernel.const_get(model_name.capitalize)
            model.init ::App.db

            app.get "/api/v1/#{model.pluralize}" do
              @records = model.all
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.get "/api/v1/#{model.pluralize}/:id" do |id|
              @records = model.get id
              @attributes = model.attributes
              @model = model

              erb :'api/models/index'
            end

            app.post "/api/v1/#{model.pluralize}" do
              params = JSON.parse(request.body.read)
              attrs = params["data"]["attributes"]

              model.create(attrs)
              status 201
              {meta:{}}.to_json
            end

            app.delete "/api/v1/#{model.pluralize}/:id" do |id|
              model.delete id
              {meta:{}}.to_json
            end

            app.patch "/api/v1/#{model.pluralize}/:id" do |id|
              params = JSON.parse(request.body.read)
              model.update(id, params["data"]["attributes"])

              {meta:{}}.to_json
            end
          end
        end
      end
    end
  end
end
