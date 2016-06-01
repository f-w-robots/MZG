module Sinatra
  module App
    module Routing
      module Auth
        def self.registered(app)
          app.get '/auth/:provider/callback' do |provider|
            params['omniauth'] = request.env['omniauth.auth'].to_hash
            env['warden'].authenticate!(:omniauth)
            redirect ENV['AUTH_REDIRECT']
          end

          app.post '/auth/signin' do
            env['warden'].authenticate!(:password)

            status 201
          end

          app.post '/auth/signup' do
            user = User.create(params['user'] || {})

            if user
              status 201
            else
              status 200
            end
          end

          app.get '/auth/logout' do
            env['warden'].raw_session.inspect
            env['warden'].logout

            redirect ENV['AUTH_REDIRECT']
          end

          app.post  '/auth/unauthenticated' do
            'wrong'
          end
        end
      end
    end
  end
end
