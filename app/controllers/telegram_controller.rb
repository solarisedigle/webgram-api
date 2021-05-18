require "net/http"
class TelegramController < ApplicationController
    def send_query(method_name, param_data)
        apikey = '1823283766:AAEou7GuSPE5dhWfDpOWKT-jT_-uMuSqAMw'
        Rails.logger.debug '---CC | Telegram response: ' + Net::HTTP.post_form(URI.parse("https://api.telegram.org/bot" + apikey + "/" + method_name), param_data).body
    end
    def index
        if !params["message"].nil?
            statuscode = 200
            message_text = params["message"]["text"]
            tg_user_id = params["message"]["from"]["id"]
            tg_chat_id = params["message"]["chat"]["id"]
            if tg_user_id != tg_chat_id
                send_query('sendMessage', {:chat_id => tg_chat_id, :text => "⚠️ Only for <u>personal</u> usage", :parse_mode => 'HTML'})
                statuscode = 203
            elsif message_text == "/start"
                send_query('sendMessage', {:chat_id => tg_user_id, :text => "<b>Hello! 🙃</b> To activate your Webgram account enter the activation key here.", :parse_mode => 'HTML'})
                statuscode = 201
            elsif message_text.match?(/\A[^.]+\.[^.]+\.[^.]+\z/)
                answer = ''
                begin
                    decoded_token = JWT.decode(message_text, @secret_key, { algorithm: 'HS256' })
                    users = User.where(id: decoded_token[0]["applicant"])
                    if users.length == 1 
                        user = users[0]
                        if user.activated == 0
                            same_th = User.where(activated: tg_user_id)
                            if same_th.length == 0
                                user.activated = tg_user_id
                                if user.save()
                                    answer = "✅ <b>Yeach!</b> <i>Your account successfully activated!</i>"
                                else
                                    answer = answer = "❌ <b>Something went wrong :/</b> <i>Try again later</i>"
                                    statuscode = 500
                                end
                            else
                                answer = "❌ <b>Something went wrong :/</b> <i>You're already connected to <u>" + same_th[0].username + "</u></i>"
                                statuscode = 409

                            end
                        else
                            answer = "⚠️ The account has <u>already</u> been activated."
                            statuscode = 205
                        end
                    else
                        answer = "❌ <b>Something went wrong :/</b> <i>User not found</i>"
                        statuscode = 404
                    end
                rescue JWT::DecodeError
                    answer = "❌ <b>Something went wrong :/</b> <i>Activation key is not valid</i>"
                    statuscode = 401
                end
                send_query('sendMessage', {:chat_id => tg_user_id, :text => answer, :parse_mode => 'HTML'})
            else
                send_query('sendMessage', {:chat_id => tg_user_id, :text => "⚠️ I'm created to <b>receive</b> only <u>activation tokens</u>", :parse_mode => 'HTML'})
                statuscode = 203
            end
        end
        render :status => statuscode
    end
end
