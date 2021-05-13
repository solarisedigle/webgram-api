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
RSpec.describe 'Webgram tests', :type => :request do
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
            :posts => [
                {
                    :title => "Crazy world",
                    :image => "https://avatars.dicebear.com/api/human/Solarise7Igl.svg",
                    :category => 2,
                    :body => "Lorem ipsum dolor <sit> !&amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum.",
                }
            ],
            :categories => [
                {
                    :name => "Usefull",
                    :description => "Lorem ipsum dolor <sit> !&amet, consectetuer adipiscing elit.",
                }
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
    it "Category Delete | Permission error" do
        delete '/api/v1/category/' + @defaults[:posts][0][:category].to_s, :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(403)
    end
    it "Category Create | Permission error" do
        post '/api/v1/category', :params => {
            :name => @defaults[:categories][0][:name],
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(403)
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
    it "Auth | Wrong token" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token] + 'FFF'}
        expect(response).to have_http_status(401)
    end
    it "Auth" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(200)
    end
    it "Post Create | Not authorised" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :category => @defaults[:posts][0][:category],
        }
        expect(response).to have_http_status(403)
    end
    it "Post Create | Wrong data" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :image => 'Not an image',
            :category => @defaults[:posts][0][:category],
        }, :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(422)
    end
    it "Post Create | As User" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :category => @defaults[:posts][0][:category],
        }, :headers => {:Authorization => @data[:first_jwt_auth_token]}
        @data["user_post"] = JSON.parse(response.body)["post"]
        expect(response).to have_http_status(200)
    end
    it "Post Create | As Admin" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :image => @defaults[:posts][0][:image],
            :category => @defaults[:posts][0][:category],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Post Like | Fake post" do
        post '/api/v1/post/-1/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "Post Like | No auth" do
        post '/api/v1/post/' + @data["user_post"]["id"].to_s + '/like'
        expect(response).to have_http_status(403)
    end
    it "Post Like" do
        post '/api/v1/post/' + @data["user_post"]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Post Like | Exists" do
        post '/api/v1/post/' + @data["user_post"]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(205)
    end
    it "Post Dislike | Fake post" do
        delete '/api/v1/post/-1/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "Post Dislike | No auth" do
        delete '/api/v1/post/' + @data["user_post"]["id"].to_s + '/like'
        expect(response).to have_http_status(403)
    end
    it "Post Dislike" do
        delete '/api/v1/post/' + @data["user_post"]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Post Dislike | Like not exists" do
        delete '/api/v1/post/' + @data["user_post"]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(205)
    end
    it "User delete | Fake id" do
        delete '/api/v1/user/-1', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "User delete" do
        debug_print(stage: 'Post 1 exists. Before deleting author')
        delete '/api/v1/user/' + @data[:users][0]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Auth | Fake user" do
        get '/', :headers => {:Authorization => @data[:first_jwt_auth_token]}
        expect(response).to have_http_status(404)
    end
    it "Category Create | Wrong data" do
        post '/api/v1/category', :params => {
            :name => '',
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(422)
    end
    it "Category Create" do
        post '/api/v1/category', :params => {
            :name => @defaults[:categories][0][:name],
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Category Delete | Fake id" do
        delete '/api/v1/category/-1', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "Category Delete" do
        delete '/api/v1/category/' + @defaults[:posts][0][:category].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Post Delete | Permission error" do
        post = Post.new()
        post.title = "Test title"
        post.body = "Test body"
        post.user = User.find_by(role: 'admin')
        post.category = Category.first()
        post.save()
        @data["tmp_post"] = post
        delete '/api/v1/post/' + post.id.to_s
        expect(response).to have_http_status(403)
    end
    it "Post Delete | Fake id" do
        delete '/api/v1/post/-1'
        expect(response).to have_http_status(404)
    end
    it "Post Delete" do
        delete '/api/v1/post/' + @data["tmp_post"]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Users list" do
        get '/api/v1/user'
        debug_print()
        expect(response).to have_http_status(200)
    end
end

