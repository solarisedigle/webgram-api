require 'jwt'
class ApplicationController < ActionController::API
    before_action :init
    def init
        @secret_key = 'oTh3r_$lD3'
        if(request.headers["Authorization"].nil?)
            @user = {:role => 'guest'}
        else
            begin
                decoded_token = JWT.decode(request.headers["Authorization"], @secret_key, { algorithm: 'HS256' })
                @user = User.where(id: decoded_token[0]["user"])
                if @user.length != 1 
                    render json: {:error => "Fatal error: User " + decoded_token[0]["user"] + " not found"}
                end
            rescue JWT::DecodeError
                render json: {:error => {:code => 401, :text => "Authorization token is not valid"}}
            end
        end
    end
end
