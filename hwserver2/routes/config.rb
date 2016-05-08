module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          settings = ::App

          app.get '/devices/manage' do
            response.headers['Access-Control-Allow-Origin'] = '*'

            if !Faye::WebSocket.websocket?(request.env)
              status 500
              return
            end

            app.manager.manage(Faye::WebSocket.new(request.env))
          end

          app.get '/:hwid' do |hwid|
            if !Faye::WebSocket.websocket?(request.env)
              status 500
              return
            end

            device_record = Device::Record.new hwid, app.db, request
            app.manager.connect device_record
          end
        end
      end
    end
  end
end
