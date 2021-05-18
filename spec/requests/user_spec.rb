require 'rails_helper'

def debug_print (stage: 'S')
    Rails.logger.debug "\n---" + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(@data) 
    Rails.logger.debug JSON.pretty_generate(User.all.map(&:attributes)) 
    Rails.logger.debug JSON.pretty_generate(Category.all.map(&:attributes)) 
    Rails.logger.debug JSON.pretty_generate(Post.all.map(&:attributes)) 
    Rails.logger.debug JSON.pretty_generate(Like.all.map(&:attributes)) 
    Rails.logger.debug "\n---/" + stage + "\n"
end
RSpec.describe 'User tests', :type => :request do
    before(:all) do
        @data = {
            users: []
        }
        @defaults = {
            :users => [
                {
                    :username => 'test_user',
                    :password => '123456',
                    :description => '<html&&&>$%45'
                },
                {
                    :username => 'second_test_user',
                    :password => 'qwerty'
                },
            ],
            :tg_user_id => 418289312,
            :secret_key => 'oTh3r_$lD3',
        }
    end
    it "User create | Wrong params" do
        post '/api/v1/user'
        expect(response).to have_http_status(422)
    end
    it "User create" do
        post '/api/v1/user', :params => {:username => @defaults[:users][0][:username], :password => @defaults[:users][0][:password], :description => @defaults[:users][0][:description]}
        expect(response).to have_http_status(200)
    end
    it "Login | Wrong data" do
        post '/api/v1/login', :params => {:username => 'bla bla', :password => 'hello'}
        expect(response).to have_http_status(401)
    end
    it "Login | Not verified" do
        post '/api/v1/login', :params => {:username => @defaults[:users][0][:username], :password => @defaults[:users][0][:password]}
        @data[:token_for_verification] = JSON.parse(body)["token"]
        expect(response).to have_http_status(403)
    end
    it "Telegram | Not private chat" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => "something", 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => 23190023}
            }
        }
        expect(response).to have_http_status(203)
    end
    it "Telegram | Start" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => "/start", 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => @defaults[:tg_user_id]}
            }
        }
        expect(response).to have_http_status(201)
    end
    it "Telegram | Not token" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => 'I\'m just text', 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => @defaults[:tg_user_id]}
            }
        }
        expect(response).to have_http_status(203)
    end
    it "Telegram | Wrong token" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => @data[:token_for_verification] + 'FFF', 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => @defaults[:tg_user_id]}
            }
        }
        expect(response).to have_http_status(401)
    end
    it "Telegram | Activation" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => @data[:token_for_verification], 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => @defaults[:tg_user_id]}
            }
        }
        expect(response).to have_http_status(200)
    end
    it "Telegram | Second activation" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => @data[:token_for_verification], 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => @defaults[:tg_user_id]}
            }
        }
        expect(response).to have_http_status(205)
    end
    it "Login" do
        post '/api/v1/login', :params => {:username => @defaults[:users][0][:username], :password => @defaults[:users][0][:password]}
        @data[:first_jwt_auth_token] = JSON.parse(body)["token"]
        @data[:users][0] = JSON.parse(body)["user"]
        expect(response).to have_http_status(200)
    end
    it "Login | As admin" do
        post '/api/v1/login', :params => {:username => 'admin', :password => 'admin'}
        @data[:admin_jwt] = JSON.parse(body)["token"]
        expect(response).to have_http_status(200)
    end
    it "Create second user" do
        post '/api/v1/user', :params => {:username => @defaults[:users][1][:username], :password => @defaults[:users][1][:password]}
        expect(response).to have_http_status(200)
    end
    it "Login | Second not verified" do
        post '/api/v1/login', :params => {:username => @defaults[:users][1][:username], :password => @defaults[:users][1][:password]}
        @data[:second_token_for_verification] = JSON.parse(body)["token"]
        expect(response).to have_http_status(403)
    end
    it "Telegram | Already connected" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => @data[:second_token_for_verification], 
                :from => {:id => @defaults[:tg_user_id]},
                :chat => {:id => @defaults[:tg_user_id]}
            }
        }
        expect(response).to have_http_status(409)
    end
    it "Telegram | Second activation" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {
            :message => {
                :text => @data[:second_token_for_verification], 
                :from => {:id => 3224},
                :chat => {:id => 3224}
            }
        }
        expect(response).to have_http_status(200)
    end
    it "Login | Second" do
        post '/api/v1/login', :params => {:username => @defaults[:users][1][:username], :password => @defaults[:users][1][:password]}
        @data[:second_jwt_auth_token] = JSON.parse(body)["token"]
        @data[:users][1] = JSON.parse(body)["user"]
        expect(response).to have_http_status(200)
    end
    it "Auth | Wrong token" do
        post '/api/v1/post', :headers => {:Authorization => @data[:first_jwt_auth_token] + 'FFF'}
        expect(response).to have_http_status(401)
    end
    it "Auth" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(200)
    end
    it "User delete | Fake id" do
        delete '/api/v1/user/-1', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "User delete | Permission error" do
        delete '/api/v1/user/' + @data[:users][0]["id"].to_s
        expect(response).to have_http_status(403)
    end
    it "User delete | By admin" do
        delete '/api/v1/user/' + @data[:users][0]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "User delete | Suicide" do
        delete '/api/v1/user/' + @data[:users][1]["id"].to_s, :headers => {:Authorization => @data[:second_jwt_auth_token]}
        expect(response).to have_http_status(200)
    end
    it "Auth | Fake user" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(401)
    end
    it "Users list" do
        get '/api/v1/user'
        debug_print()
        expect(response).to have_http_status(200)
    end
end

