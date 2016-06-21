module Sinatra
  module App
    module Routing
      module Auth
        def self.registered(app)
          app.get '/auth/:provider/callback' do |provider|
            params['omniauth'] = request.env['omniauth.auth'].to_hash
            if !env['warden'].user
              env['warden'].authenticate!(:omniauth)
              redirect ENV['AUTH_REDIRECT']
            else
              data = env['omniauth.auth'].to_hash
              existing_user = User.where({"providers.#{data['provider']}.uid" => data['uid']}).first
              user = env['warden'].user

              if !existing_user && (!env['warden'].user['providers'] || env['warden'].user['providers'][provider])
                user['providers'] ||= {}
                user['providers'][provider] = data
                user.save
              end

              redirect ENV['AUTH_REDIRECT'] + '/profile'
            end

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
            user.merge!({'username' => '', 'password' =>  '', 'email' => ''}.select { |k| !user.keys.include? k })

            user = User.create(user)
            if user.errors.size > 0
              status 403
              {meta: {errors: user.errors.map{|k,e|e}}}.to_json
            else
              app.mailer.new_user user['email'], user['confirmation_code']
              env['warden'].authenticate!(:password)
            end
          end

          app.get '/auth/logout' do
            env['warden'].raw_session.inspect
            env['warden'].logout

            redirect ENV['AUTH_REDIRECT']
          end

          app.post '/auth/unauthenticated' do
            status 403
          end

          app.get '/auth/confirm/:confirmation_code' do |confirmation_code|
            User.where(:confirmation_code => confirmation_code).update(confirmed: true)
          end
        end
      end
    end
  end
end
