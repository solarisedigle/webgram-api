require 'rails_helper'

RSpec.describe 'User tests', :type => :request do
    before(:all) do
        @data = {
            users: []
        }
        @defaults = {
            :users => [
                {
                    :username => 'test_user',
                    :password => '123456'
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
    it "Creating | Wrong params" do
        post '/api/v1/user/new'
        expect(response).to have_http_status(422)
    end
    it "Creating" do
        post '/api/v1/user/new', :params => {:username => @defaults[:users][0][:username], :password => @defaults[:users][0][:password]}
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
    it "Creating second user" do
        post '/api/v1/user/new', :params => {:username => @defaults[:users][1][:username], :password => @defaults[:users][1][:password]}
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
    it "Auth" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(200)
    end
    it "Auth | Wrong token" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token] + 'FFF'}
        expect(response).to have_http_status(401)
    end
    it "Delete | Fake id" do
        delete '/api/v1/user/-1/oTh3r_$lD3'
        expect(response).to have_http_status(404)
    end
    it "Delete" do
        delete '/api/v1/user/' + @data[:users][0]["id"].to_s + '/oTh3r_$lD3'
        expect(response).to have_http_status(200)
    end
    it "Auth | Fake user" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(404)
    end

    it "Users list" do
        get '/api/v1/user'
        Rails.logger.debug body
        Rails.logger.debug JSON.pretty_generate(@data)
        expect(response).to have_http_status(200)
    end
end

