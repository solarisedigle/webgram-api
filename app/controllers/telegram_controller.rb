class TelegramController < ApplicationController
    require 'json'
    def send_message(method_name, param_data)
        apikey = '1823283766:AAEou7GuSPE5dhWfDpOWKT-jT_-uMuSqAMw'
        return HTTParty.get("https://api.telegram.org/bot" + apikey + "/" + method_name,
            :body => param_data)
    end
    def index
        if params[:secret] != @secret_key
            render(json: {:error => {:code => 401, :text => "Secret key is not valid"}}) and return
        end
        puts params.to_json
        puts send_message('sendMessage', {:chat_id => 418289311, :text => params.to_json, :parse_mode => 'HTML'}).response.body
    end
end
