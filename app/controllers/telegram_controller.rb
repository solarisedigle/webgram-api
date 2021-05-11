require "net/http"
class TelegramController < ApplicationController
    def send_message(method_name, param_data)
        apikey = '1823283766:AAEou7GuSPE5dhWfDpOWKT-jT_-uMuSqAMw'
        return Net::HTTP.post_form(URI.parse("https://api.telegram.org/bot" + apikey + "/" + method_name), param_data)
    end
    def index
        if params[:secret] != @secret_key
            render(json: {:error => {:code => 401, :text => "Secret key is not valid"}}) and return
        end
        if !params["message"].nil?
            message_text = params["message"]["text"]
            tg_user_id = params["message"]["from"]["id"]
            tg_chat_id = params["message"]["chat"]["id"]
            if tg_user_id != tg_chat_id
                puts send_message('sendMessage', {:chat_id => tg_chat_id, :text => "⚠️ Only for <u>personal</u> usage", :parse_mode => 'HTML'}).body
            elsif message_text == "/start"
                puts send_message('sendMessage', {:chat_id => tg_user_id, :text => "<b>Hello! 🙃</b> To activate your Webgram account enter the activation key here.", :parse_mode => 'HTML'}).body
            elsif message_text.match?(/\A[^.]+\.[^.]+\.[^.]+\z/)
                answer = ''
                begin
                    decoded_token = JWT.decode(message_text, @secret_key, { algorithm: 'HS256' })
                    users = User.where(id: decoded_token[0]["user"])
                    if users.length == 1 
                        user = users[0]
                        if user.activated == 0
                            user.activated = tg_user_id
                            if user.save()
                                answer = "✅ <b>Yeach!</b> <i>Your account successfully activated!</i>"
                            else
                                answer = answer = "❌ <b>Something went wrong :/</b> <i>Try again later</i>"
                            end
                        else
                            answer = "⚠️ The account has <u>already</u> been activated"
                        end
                    else
                        answer = "❌ <b>Something went wrong :/</b> <i>User not found</i>"
                    end
                rescue JWT::DecodeError
                    answer = "❌ <b>Something went wrong :/</b> <i>Activation key is not valid</i>"
                end
                puts send_message('sendMessage', {:chat_id => tg_user_id, :text => answer, :parse_mode => 'HTML'}).response.body
            else
                puts send_message('sendMessage', {:chat_id => tg_user_id, :text => "⚠️ I'm created to <b>receive</b> only <u>activation tokens</u>", :parse_mode => 'HTML'}).response.body
            end
        end
    end
end
