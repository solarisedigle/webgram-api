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
            render json: {:success => true, :user=> user}, status: 200
        else
            render json: {:success => false, :errors=> user.errors}, status: 422
        end
    end
    def print_all
        render json: User.all
    end
    def user_data(user_id)
        user = User.where(id: user_id)
        if user.length > 0
            result = {
                :id => user[0]["id"],
                :username => user[0]["username"],
                :description => user[0]["description"],
                :last_action => user[0]["last_action"],
                :role => user[0]["role"],
            }
        else
            result = {:error => "Fatal error: User " + user_id + " not found"}
            statuscode = 404
        end
        return result
    end
    def view
        statuscode = 200
        render json: user_data(params[:id]), status: statuscode
    end
    def kick
        statuscode = 200
        user = User.where(id: params[:id])
        if user.length > 0
            if !user[0].destroy()
                statuscode = 500
            end
        else
            result = {:error => "Fatal error: User " + params[:id] + " not found"}
            statuscode = 404
        end
        render json: result, status: statuscode
    end
    def login
        result = {}
        statuscode = 200
        if(!params[:username].nil? && !params[:password].nil?)
            users = User.where(username: params[:username], password: Digest::SHA2.hexdigest(params[:username] + @secret_key + params[:password]))
            if users.length == 1
                user = users[0]
                if user.activated == 0
                    token = JWT.encode({applicant: user.id}, @secret_key, 'HS256')
                    result = {:success => false, :token => token, :reason => "Account is not verified"}
                    statuscode = 403
                else
                    token = JWT.encode({user: user.id, exp: Time.now.to_i + 300}, @secret_key, 'HS256')
                    result = {:success => true, :token => token, :user => user_data(user.id)}
                end
            else
                result = {:success => false, :reason => "Login failed"}
                statuscode = 401
            end
        else
            result = {:success => false, :reason => "Incorrect query"}
            statuscode = 422
        end
        render json: result, status: statuscode
    end
end
