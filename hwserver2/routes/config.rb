module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          settings = ::App

          app.get '/devices/manage' do
            response.headers['Access-Control-Allow-Origin'] = '*'
            return if !request.websocket?
            app.manager.manage request
          end

          app.get '/control/:hwid' do |hwid|
            # device = ::App.device_manager.device(hwid)
            # return '' if !device || !device.manual? || device.group_interface?
            #
            # response = device.interface.start(request)
            # response
          end

          app.get '/:hwid' do |hwid|
            if !request.websocket?
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
