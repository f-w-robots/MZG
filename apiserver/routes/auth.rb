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
            if(params['user']['password'] != params['user']['password_confirmation'])
              status 403
              return {meta: {errors: 'password confimation'}}.to_json
            end

            user = params['user'] || {}
            user.merge!({'password' =>  '', 'username' => ''}.select { |k| !user.keys.include? k })

            user = User.create(user)
            if user.errors.size > 0
              status 403
              {meta: {errors: user.errors.map{|k,e|e}}}.to_json
            else
              env['warden'].authenticate!(:password)
            end
          end

          app.get '/auth/logout' do
            env['warden'].raw_session.inspect
            env['warden'].logout

            redirect ENV['AUTH_REDIRECT']
          end

          app.post  '/auth/unauthenticated' do
            status 403
          end
        end
      end
    end
  end
end
