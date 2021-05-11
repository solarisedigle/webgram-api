class UserController < ApplicationController
    def register
        user = User.new
        user.username = params[:username]
        user.password = params[:password].nil? ? '' : Digest::SHA2.hexdigest(params[:username] + @secret_key + params[:password])
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
    def view
        user = User.where(id: params[:id])
        if user.length > 0
            result = {
                :username => user[0]["username"],
                :description => user[0]["description"],
                :last_action => user[0]["last_action"],
                :role => user[0]["role"],
            }
        else
            result = {:error => "Fatal error: User " + params[:id] + " not found"}
        end
        render json: result
    end
    def login
        result = {}
        if(!params[:username].nil? && !params[:password].nil?)
            user = User.where(username: params[:username], password: Digest::SHA2.hexdigest(params[:username] + @secret_key + params[:password]))
            if user.length == 1
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
