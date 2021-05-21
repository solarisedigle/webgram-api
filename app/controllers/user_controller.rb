require "net/http"
class UserController < ApplicationController
    def send_query(method_name, param_data)
        Net::HTTP.post_form(URI.parse("https://api.telegram.org/bot" + ENV['WG_TH_KEY'] + "/" + method_name), param_data).body
    end
    def register
        user = User.new
        user.username = params[:username]
        user.password = (params[:password].blank?) ? '' : Digest::SHA2.hexdigest(params[:username] + @secret_key + params[:password])
        user.description = !params[:description].blank? ? CGI.escapeHTML(params[:description]) : ''
        user.activated = 0
        user.role = 'user'
        user.last_action = Time.now.to_i
        if(user.save)
            render json: {:success => true, :user=> user}, status: 200
        else
            render json: {:errors=> user.errors}, status: 422
        end
    end
    def print_all
        render json: User.all
    end
    def user_data_format(user)
        result = {
            :id => user["id"],
            :username => user["username"],
            :description => user["description"],
            :last_action => user["last_action"],
            :role => user["role"],
        }
        return result
    end
    def user_data(user_id)
        statuscode = 200
        user = User.where(id: user_id)
        if user.length > 0
            result = user_data_format(user[0])
        else
            result = {:error => "Fatal error: User " + user_id + " not found"}
            statuscode = 404
        end
        return result, statuscode
    end
    def view
        user = user_data(params[:id])
        render json: user[0], status: user[1]
    end
    def get_me
        user = user_data(@user["id"])
        render json: user[0], status: user[1]
    end
    def get_relation
        statuscode = 404;
        result = {}
        if(@user["role"] != 'guest')
            if @user["id"].to_i == params[:id].to_i
                result = {relation: 'owner'}
                statuscode = 200
            else
                if Subscription.where(user_id: params[:id], subscriber_id: @user["id"]).length > 0
                    result = {relation: 'subscriber'}
                    statuscode = 200
                else
                    result = {}
                    statuscode = 204
                end
            end
        end
        render json: result, status: statuscode
    end
    def profile
        statuscode = 200
        result = {}
        user = User.active.where(username: params[:username])
        if(user.length > 0)
            result = {
                :user => user_data_format(user[0]),
                :posts => user[0].posts.size,
                :subscribers => user[0]["count_of_subscribers"],
                :subscriptions => Subscription.where(subscriber: user).count,
                :likes => user[0].posts.sum(:count_of_likes),
                :comments => Comment.where(user: user[0]).count,
                :self => @user["id"] == user[0]["id"],
            }
        else
            statuscode = 404
        end
        render json: result, status: statuscode
    end
    def kick
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin" || @user["id"].to_s == params[:id])
            user = User.where(id: params[:id])
            if user.length > 0
                if !user[0].destroy()
                    statuscode = 500
                    result = {:error => "Fatal server error: User " + params[:id] + " destroy"}
                end
            else
                result = {:error => "Fatal error: User " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Permission eror"}
            statuscode = 403
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
                    result = {:token => token, :error => "Account is not verified"}
                    statuscode = 403
                else
                    token = JWT.encode({user: user.id, exp: Time.now.to_i + 3600}, @secret_key, 'HS256')
                    result = {:token => token, :user => user_data_format(user)}
                end
            else
                result = {:error => "Login failed"}
                statuscode = 401
            end
        else
            result = {:error => "Incorrect query"}
            statuscode = 422
        end
        render json: result, status: statuscode
    end
    def subscribe
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            user = User.where(id: params[:id])
            if user.length > 0
                if Subscription.find_by(user: user[0], subscriber: @user).nil?
                    subscription = Subscription.new()
                    subscription.user = user[0]
                    subscription.subscriber = @user
                    if subscription.save()
                        send_query('sendMessage', {:chat_id => user[0].activated, :text => "👣 New subscriber! >> <a href=\"https://webgram.shumik.pp.ua/" + @user["username"] + "\">" + @user["username"] + "</a>", :parse_mode => 'HTML'})
                        result = {relation: 'subscriber'}
                        statuscode = 200
                    else
                        result = {:error => "Fatal server error: Subscription"}
                        statuscode = 500
                    end
                else
                    result = {:error => "Subscription already exists"}
                    statuscode = 205
                end
            else
                result = {:error => "Fatal error: User " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can interact"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def unsubscribe
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            user = User.where(id: params[:id])
            if user.length > 0
                if !(subscription = Subscription.find_by(user: user[0], subscriber: @user)).nil?
                    if subscription.destroy()
                        result = {}
                        statuscode = 200
                    else
                        result = {:error => "Fatal server error: Unsubscription"}
                        statuscode = 500
                    end
                else
                    result = {:error => "Subscription already don't exists"}
                    statuscode = 205
                end
            else
                result = {:error => "Fatal error: User " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can interact"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def search_users
        if !params[:user] 
            params[:user] = ''
        end
        users = User.active.where("lower(username) like '%#{params[:user].downcase()}%'").limit(7).order("count_of_subscribers DESC")
        render json: {users: users}, status: 200
    end
    def edit_description
        statuscode = 200
        result = {:success => true}
        if(@user[:role] != 'guest')
            if(!params[:description].nil? && params[:description].is_a?(String))
                @user.description = CGI.escapeHTML(params[:description])
                if !@user.save()
                    statuscode = 500
                    result = {:error => 'Server error'}
                end
                
            else
                statuscode = 422
                result = {:error => 'Invalid data'}
            end
        else
            statuscode = 403
            result = {:error => 'Permission error'}
        end
        render json: result, status: statuscode
    end
    def promote
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin")
            user = User.where(id: params[:id])
            if user.length > 0
                user[0]["role"] = "admin"
                if !user[0].save()
                    statuscode = 500
                    result = {:error => "Fatal server error: User " + params[:id] + " destroy"}
                end
            else
                result = {:error => "Fatal error: User " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Permission eror"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
end
