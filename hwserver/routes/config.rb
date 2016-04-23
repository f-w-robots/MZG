module Sinatra
  module App
    module Routing
      module Config
        def self.registered(app)
          settings = ::App

          app.get '/devices/manage' do
            response.headers['Access-Control-Allow-Origin'] = '*'
            return if !request.websocket?
            ::App.device_manager.open_socket request
          end

          app.get '/group/info/:name' do |name|
            response.headers['Access-Control-Allow-Origin'] = '*'
            group = ::App.groups[name]
            if !group
              status 404
            else
              group.options[:info].to_s
            end
          end

          app.get '/group/communicate/:name' do |name|
            group = ::App.groups[name]
            return if !group
            group.start_interface request
          end

          app.post '/group/up/:name' do |name|
            response.headers['Access-Control-Allow-Origin'] = '*'
            group_db = DB::Group.new(name, ::App.db)

            group = group_db.class_const.new group_db

            if ::App.groups[name]
              ::App.groups[name].destroy
            end
            ::App.groups[name] = group

            group.start
          end

          app.get '/control/:hwid' do |hwid|
            device = ::App.device_manager.device(hwid)
            return '' if !device || !device.manual? || device.group_interface?

            response = device.interface.start(request)
            response
          end

          app.get '/:hwid' do |hwid|
            return if !request.websocket?
            puts "Connection from #{hwid}, ip: #{request.ip}"

            bricks = Bricks.new hwid, settings.device_manager

            if ::App.device_manager.device(hwid)
              ::App.device_manager.device(hwid).destroy
            end

            device_record = DB::Device.new(hwid, settings.db)
            unless device_record.record
              puts "No record hwid #{hwid.to_s}"
              return
            end
            device = Device.new hwid, bricks
            bricks.push device

            if device_record.proxy?
              proxy_driver = device_record.proxy_driver
              proxy = Proxy.new(hwid, proxy_driver)
              bricks.push proxy
            end

            if device_record.group?
              group = ::App.groups[device_record.group]
              if !group
                status 404
                return 'runned group not found'
              end
              bricks.push_group group
            end

            if device_record.manual?
              if !bricks.manual?
                backend = Control.new hwid
                bricks.push_interface backend
              end
            else
              backend = Algorithm.new hwid, device_record.algorithm, bricks
              backend.start request
              bricks.push backend
            end
            bricks.connect

            ::App.device_manager.device_add(hwid, bricks)

            if device_record.manual?
              ::App.device_manager.update_device
            end

            response = device.start(request)

            proxy.start if proxy

            response
          end
        end
      end
    end
  end
end
