require 'rails_helper'

def debug_print (stage: 'S')
    Rails.logger.debug "\n---" + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(User.all.map(&:attributes))
    Rails.logger.debug JSON.pretty_generate(Subscription.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
def debug_print_users (stage: 'S')
    Rails.logger.debug "\n---Users " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(User.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
def debug_print_subscriptions (stage: 'S')
    Rails.logger.debug "\n---Subscriptions " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Subscription.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
RSpec.describe 'Subscribe tests', :type => :request do
    before(:all) do
        @data = {
            :users => {}
        }
        @defaults = {
            :secret_key => 'oTh3r_$lD3',
            :password => '123456',
        }
    end
    it "Login | As admin" do
        post '/api/v1/login', :params => {:username => 'admin', :password => 'admin'}
        @data[:admin_jwt] = JSON.parse(body)["token"]
        expect(response).to have_http_status(200)
    end
    it "User create | alex" do
        post '/api/v1/user', :params => {:username => 'alex', :password => @defaults[:password]}
        @data[:users][:alex] = JSON.parse(body)["user"]
        expect(response).to have_http_status(200)
    end
    it "Get token | alex" do
        post '/api/v1/login', :params => {:username => 'alex', :password => @defaults[:password]}
        @data[:alex_verification] = JSON.parse(body)["token"]
        expect(response).to have_http_status(403)
    end
    it "Activate | alex" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {:message => {:text => @data[:alex_verification], :from => {:id => 4},:chat => {:id => 4}}}
        expect(response).to have_http_status(200)
    end
    it "Login | alex" do
        post '/api/v1/login', :params => {:username => 'alex', :password => @defaults[:password]}
        @data[:alex_jwt_auth_token] = JSON.parse(body)["token"]
        expect(response).to have_http_status(200)
    end

    it "User create | john" do
        post '/api/v1/user', :params => {:username => 'john', :password => @defaults[:password]}
        @data[:users][:john] = JSON.parse(body)["user"]
        expect(response).to have_http_status(200)
    end
    it "Get token | john" do
        post '/api/v1/login', :params => {:username => 'john', :password => @defaults[:password]}
        @data[:john_verification] = JSON.parse(body)["token"]
        expect(response).to have_http_status(403)
    end
    it "Activate | john" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {:message => {:text => @data[:john_verification], :from => {:id => 2},:chat => {:id => 2}}}
        expect(response).to have_http_status(200)
    end
    it "Login | john" do
        post '/api/v1/login', :params => {:username => 'john', :password => @defaults[:password]}
        @data[:john_jwt_auth_token] = JSON.parse(body)["token"]
        expect(response).to have_http_status(200)
    end

    it "User create | mark" do
        post '/api/v1/user', :params => {:username => 'mark', :password => @defaults[:password]}
        @data[:users][:mark] = JSON.parse(body)["user"]
        expect(response).to have_http_status(200)
    end
    it "Get token | mark" do
        post '/api/v1/login', :params => {:username => 'mark', :password => @defaults[:password]}
        @data[:mark_verification] = JSON.parse(body)["token"]
        expect(response).to have_http_status(403)
    end
    it "Activate | mark" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {:message => {:text => @data[:mark_verification], :from => {:id => 5},:chat => {:id => 5}}}
        expect(response).to have_http_status(200)
    end
    it "Login | mark" do
        post '/api/v1/login', :params => {:username => 'mark', :password => @defaults[:password]}
        @data[:mark_jwt_auth_token] = JSON.parse(body)["token"]
        expect(response).to have_http_status(200)
    end

    it "User create | bella" do
        post '/api/v1/user', :params => {:username => 'bella', :password => @defaults[:password]}
        @data[:users][:bella] = JSON.parse(body)["user"]
        expect(response).to have_http_status(200)
    end
    it "Get token | bella" do
        post '/api/v1/login', :params => {:username => 'bella', :password => @defaults[:password]}
        @data[:bella_verification] = JSON.parse(body)["token"]
        expect(response).to have_http_status(403)
    end
    it "Activate | bella" do
        post '/api/telegramHandler/oTh3r_$lD3', :params => {:message => {:text => @data[:bella_verification], :from => {:id => 3},:chat => {:id => 3}}}
        expect(response).to have_http_status(200)
    end
    it "Login | bella" do
        post '/api/v1/login', :params => {:username => 'bella', :password => @defaults[:password]}
        @data[:bella_jwt_auth_token] = JSON.parse(body)["token"]
        expect(response).to have_http_status(200)
        debug_print_users(stage: 'Users created')
    end

    it "Subscribe | No auth" do
        post '/api/v1/user/' + @data[:users][:bella]["id"].to_s + '/subscribe'
        expect(response).to have_http_status(403) 
    end
    it "Subscribe Mark | Fake user" do
        post '/api/v1/user/-1/subscribe', 
            :headers => {:Authorization => @data[:mark_jwt_auth_token]}
        expect(response).to have_http_status(404) 
    end
    it "Subscribe Mark | To Bella" do
        post '/api/v1/user/' + @data[:users][:bella]["id"].to_s + '/subscribe', 
            :headers => {:Authorization => @data[:mark_jwt_auth_token]}
        expect(response).to have_http_status(200) 
    end
    it "Subscribe Mark | To Bella again" do
        post '/api/v1/user/' + @data[:users][:bella]["id"].to_s + '/subscribe', 
            :headers => {:Authorization => @data[:mark_jwt_auth_token]}
        expect(response).to have_http_status(205) 
    end
    
    it "Subscribe Alex | To John" do
        post '/api/v1/user/' + @data[:users][:john]["id"].to_s + '/subscribe', 
            :headers => {:Authorization => @data[:alex_jwt_auth_token]}
        expect(response).to have_http_status(200) 
    end
    it "Subscribe Bella | To John" do
        post '/api/v1/user/' + @data[:users][:john]["id"].to_s + '/subscribe', 
            :headers => {:Authorization => @data[:bella_jwt_auth_token]}
        expect(response).to have_http_status(200) 
        debug_print_subscriptions(stage: 'Users subscribed')
    end

    it "Destroy Alex | Unsubscribe from John" do
        delete '/api/v1/user/' + @data[:users][:alex]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_subscriptions(stage: 'Alex destroyed')
    end
    it "Destroy John | Unsubscribe Bella" do
        delete '/api/v1/user/' + @data[:users][:john]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_subscriptions(stage: 'John destroyed')
    end
    it "Subscribe Mark | From Bella" do
        delete '/api/v1/user/' + @data[:users][:bella]["id"].to_s + '/subscribe', 
            :headers => {:Authorization => @data[:mark_jwt_auth_token]}
        expect(response).to have_http_status(200)
        debug_print_subscriptions(stage: 'John destroyed')
    end
end

