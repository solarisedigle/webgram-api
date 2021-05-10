require 'digest'
class UserController < ApplicationController
    def register
        user = User.new
        user.username = params[:username]
        user.password = params[:password]
        user.description = params[:description]
        user.activated = 0
        user.role = 'user'
        user.last_action = Time.now.to_i
        if(user.save)
            render json: {:success => true, :user=> user}
        else
            render json: {:success => false, :errors=> user.errors}
        end
    end
    def print_all
        render json: User.all
    end
    def login
        result = {}
        if(!params[:username].nil? && !params[:password].nil?)
            user = User.where(username: params[:username], password: params[:password])
            if user.length > 0
                user = user[0]
                token = JWT.encode({user: user.id, exp: Time.now.to_i + 300}, @secret_key, 'HS256')
                result = {:success => true, :token => token}
            else
                result = {:success => false, :reason => "Login failed"}
            end
        else
            result = {:success => false, :reason => "Incorrect query"}
        end
        render json: result
    end
end
