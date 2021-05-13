require 'rails_helper'

def debug_print_users (stage: 'S')
    Rails.logger.debug "\n---Users " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(User.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
def debug_print_posts (stage: 'S')
    Rails.logger.debug "\n---Posts " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Post.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
def debug_print_likes (stage: 'S')
    Rails.logger.debug "\n---Likes " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Like.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
def debug_print_categories (stage: 'S')
    Rails.logger.debug "\n---Categories " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Category.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
RSpec.describe 'Posts tests', :type => :request do
    before(:all) do
        @data = {
            :users => {}
        }
        @defaults = {
            :secret_key => 'oTh3r_$lD3',
            :password => '123456',
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
        debug_print_users(stage: 'Created test users')
    end
    it "Category Create | Wrong data" do
        post '/api/v1/category', :params => {
            :name => '',
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(422)
    end
    it "Category Create | Permission error" do
        post '/api/v1/category', :params => {
            :name => @defaults[:categories][0][:name],
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:john_jwt_auth_token]}
        expect(response).to have_http_status(403)
    end
    it "Category Create" do
        post '/api/v1/category', :params => {
            :name => @defaults[:categories][0][:name],
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        @data[:tmp_category] = JSON.parse(response.body)["category"]
        expect(response).to have_http_status(200)
    end
    it "Post Create | Not authorised" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :category => @data[:tmp_category]["id"],
        }
        expect(response).to have_http_status(403)
    end
    it "Post Create | Wrong data" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :image => 'Not an image',
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:alex_jwt_auth_token]}
        expect(response).to have_http_status(422)
    end
    it "Post Create | User delete test" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:alex_jwt_auth_token]}
        @data[:alex_post] = JSON.parse(response.body)["post"]
        expect(response).to have_http_status(200)
    end
    it "Post Create | Admin delete john's post" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:john_jwt_auth_token]}
        @data[:john_post] = JSON.parse(response.body)["post"]
        expect(response).to have_http_status(200)
    end
    it "Post Create | Simple delete" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :image => @defaults[:posts][0][:image],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        @data[:admin_post] = JSON.parse(response.body)["post"]
        debug_print_posts(stage: 'Posts created')
    end
    it "Post Like | Fake post" do
        post '/api/v1/post/-1/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "Post Like | No auth" do
        post '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like'
        expect(response).to have_http_status(403)
    end
    it "Post Like" do
        post '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Post Like | Exists" do
        post '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(205)
        debug_print_likes(stage: 'Like')
    end
    it "Post Dislike | Fake post" do
        delete '/api/v1/post/-1/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "Post Dislike | No auth" do
        delete '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like'
        expect(response).to have_http_status(403)
    end
    it "Post Dislike" do
        delete '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
    it "Post Dislike | Like not exists" do
        delete '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(205)
        debug_print_likes(stage: 'Dislike')
    end
    it "Post Like | User delete" do
        post '/api/v1/post/' + @data[:alex_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_likes(stage: 'New like')
    end
    it "User delete | Post destroy" do
        delete '/api/v1/user/' + @data[:users][:alex]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Post destroyed after user')
        debug_print_likes(stage: 'Likes destroyed after user')
    end
    it "Post Like | Post delete" do
        post '/api/v1/post/' + @data[:admin_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:john_jwt_auth_token]}
        expect(response).to have_http_status(200)
        debug_print_likes(stage: 'John liked admin\'s post')
    end
    it "Post Delete | Permission error" do
        delete '/api/v1/post/' + @data[:admin_post]["id"].to_s
        expect(response).to have_http_status(403)
    end
    it "Post Delete | Fake id" do
        delete '/api/v1/post/-1'
        expect(response).to have_http_status(404)
    end
    it "Post Delete" do
        delete '/api/v1/post/' + @data[:admin_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Simple post deleted')
        debug_print_likes(stage: 'Likes destroyed after post')
    end
    it "Post Delete | Admin roots" do
        delete '/api/v1/post/' + @data[:john_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'John\'s post deleted by admin')
    end
    it "Post Create | Category delete" do
        post '/api/v1/post', :params => {
            :title => @defaults[:posts][0][:title],
            :body => @defaults[:posts][0][:body],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:john_jwt_auth_token]}
        @data[:tmp_post] = JSON.parse(response.body)["post"]
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Post exists before category delete')
    end
    it "Post Like | Category delete" do
        post '/api/v1/post/' + @data[:tmp_post]["id"].to_s + '/like', :headers => {:Authorization => @data[:john_jwt_auth_token]}
        expect(response).to have_http_status(200)
        debug_print_likes(stage: 'Like exists before category delete')
    end
    it "Category Delete | Permission error" do
        delete '/api/v1/category/' + @data[:tmp_category]["id"].to_s, :headers => {:Authorization => @data[:john_jwt_auth_token]}
        expect(response).to have_http_status(403)
    end
    it "Category Delete | Fake id" do
        delete '/api/v1/category/-1', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "Category Delete" do
        delete '/api/v1/category/' + @data[:tmp_category]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Post destroyed after category')
        debug_print_likes(stage: 'Like destroyed after post')
    end
end

