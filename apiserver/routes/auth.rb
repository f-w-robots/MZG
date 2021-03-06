module Sinatra
  module App
    module Routing
      module Auth
        def self.registered(app)
          app.get '/auth/:provider/callback' do |provider|
            data = env['omniauth.auth'].to_hash
            current_user = env['warden'].user

            if !current_user
              existing_user_by_email = User.where(email: data["info"]["email"]).first

              if !existing_user_by_email
                env['warden'].authenticate!(:omniauth)
                app.mailer.new_user env['warden'].user
                redirect ENV['AUTH_REDIRECT']
              elsif User.where({"providers.#{data['provider']}.uid" => data['uid']}).first
                env['warden'].authenticate!(:omniauth)
                redirect ENV['AUTH_REDIRECT']
              elsif (!existing_user_by_email['providers'] || !existing_user_by_email['providers']['github'])
                existing_user_by_email.add_provider!(provider, data)
                existing_user_by_email[:confirmed] = true
                existing_user_by_email.save

                env['warden'].authenticate!(:omniauth)
                redirect ENV['AUTH_REDIRECT']
              else
                redirect ENV['AUTH_REDIRECT'] + '/?error=Email on this github account used for another account'
              end
            else
              existing_user = User.where({"providers.#{data['provider']}.uid" => data['uid']}).first

              if !existing_user && (!current_user['providers'] || !current_user['providers'][provider])
                current_user.add_provider!(provider, data)
              end

              redirect ENV['AUTH_REDIRECT'] + '/profile'
            end

          end

          app.get('/auth/:provider/disconnect') do |provider|
            user = env['warden'].user
            user[:providers].delete(provider)
            providers = user[:providers]
            user.providers = nil
            user.save
            user.providers = providers
            user.save

            redirect ENV['AUTH_REDIRECT'] + '/profile'
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

            params['user'].delete('password_confirmation')

            user = params['user'] || {}
            user.merge!({'username' => '', 'password' =>  '', 'email' => ''}.select { |k| !user.keys.include? k })

            user = User.create(user)
            if user.errors.size > 0
              status 403
              {meta: {errors: user.errors.map{|k,e|e}}}.to_json
            else
              app.mailer.new_user user
              params['user']['login'] = params['user'].delete 'email'

              env['warden'].authenticate!(:password)
            end
          end

          app.get '/auth/logout' do
            env['warden'].logout

            redirect ENV['AUTH_REDIRECT']
          end

          app.post '/auth/unauthenticated' do
            status 403
            {meta: {errors: 'undefined error'}}.to_json
          end

          app.get '/auth/confirm/:confirmation_code' do |confirmation_code|
            User.where(:confirmation_code => confirmation_code).update(confirmed: true)
          end

          app.post '/auth/forgot_password' do
            user = User.where(email: params[:email]).first
            if user
              user[:forgot_password_code] = (0...150).map { ('a'..'z').to_a[rand(26)] }.join
              user.save
              app.mailer.forgot_password user
              status 201
            else
              status 200
            end
          end

          app.post '/auth/update_password' do
            if params[:key] && params[:key].size > 50
              user = User.where(forgot_password_code: params[:key]).first
              if user
                if params[:password] == params[:password_confirmation]
                  user.password = params[:password]
                  user.forgot_password_code = nil
                  user.save
                  status 201
                end
              end
            end
          end
        end
      end
    end
  end
end
