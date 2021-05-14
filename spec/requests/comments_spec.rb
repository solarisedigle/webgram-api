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
def debug_print_comments (stage: 'S')
    Rails.logger.debug "\n---Comments " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Comment.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
RSpec.describe 'Comments tests', :type => :request do
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
          :comments => [
            {
                :body => "Lorem ipsum dolor <sit> !&amet, consectetuer adipiscing elit.",
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
      @data[:alex] = JSON.parse(body)
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
      @data[:john] = JSON.parse(body)
      expect(response).to have_http_status(200)
      debug_print_users(stage: 'Users created for tests')
  end
  it "Category Create" do
      post '/api/v1/category', :params => {
          :name => @defaults[:categories][0][:name],
          :description => @defaults[:categories][0][:description],
      }, :headers => {:Authorization => @data[:admin_jwt]}
      @data[:tmp_category] = JSON.parse(response.body)["category"]
      expect(response).to have_http_status(200)
  end
  it "Post Create" do
      post '/api/v1/post', :params => {
          :title => @defaults[:posts][0][:title],
          :body => @defaults[:posts][0][:body],
          :image => @defaults[:posts][0][:image],
          :category => @data[:tmp_category]["id"],
      }, :headers => {:Authorization => @data[:admin_jwt]}
      expect(response).to have_http_status(200)
      @data[:tmp_post] = JSON.parse(response.body)["post"]
      debug_print_posts(stage: 'Posts created')
  end
  it "Comment Post | Wrong data" do
    post '/api/v1/post/' + @data[:tmp_post]["id"].to_s + '/comment', :params => {
        :body => '',
    }, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(422)
  end
  it "Comment Post | Fake post id" do
    post '/api/v1/post/-1/comment', :params => {
        :body => @defaults[:comments][0][:body],
    }, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(404)
  end
  it "Comment Post | No auth" do
    post '/api/v1/post/' + @data[:tmp_post]["id"].to_s + '/comment', :params => {
        :body => @defaults[:comments][0][:body],
    }
    expect(response).to have_http_status(403)
  end
  it "Comment Post" do
    post '/api/v1/post/' + @data[:tmp_post]["id"].to_s + '/comment', :params => {
        :body => @defaults[:comments][0][:body],
    }, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(200)
    @data[:tmp_comment] = JSON.parse(response.body)["comment"]
    debug_print_comments(stage: 'Comment created')
  end
  it "Comment Delete | No auth" do
    delete '/api/v1/comment/' + @data[:tmp_comment]["id"].to_s
    expect(response).to have_http_status(403)
  end
  it "Comment Delete | Fake user" do
    delete '/api/v1/comment/' + @data[:tmp_comment]["id"].to_s, :headers => {:Authorization => @data[:john]["token"]}
    expect(response).to have_http_status(403)
  end
  it "Comment Delete | Fake comment" do
    delete '/api/v1/comment/-1', :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(404)
  end
  it "Comment Delete" do
    delete '/api/v1/comment/' + @data[:tmp_comment]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(200)
    debug_print_comments(stage: 'Comment deleted')
  end
  it "Comment Post | Admin delete user's" do
    post '/api/v1/post/' + @data[:tmp_post]["id"].to_s + '/comment', :params => {
        :body => @defaults[:comments][0][:body],
    }, :headers => {:Authorization => @data[:john]["token"]}
    expect(response).to have_http_status(200)
    @data[:tmp_comment] = JSON.parse(response.body)["comment"]
    debug_print_comments(stage: 'Comment for admin_deleting created')
  end
  it "Comment Delete | By admin" do
    delete '/api/v1/comment/' + @data[:tmp_comment]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(200)
    debug_print_comments(stage: 'User comment deleted by admin')
  end
  it "Comment Post | Post delete" do
    post '/api/v1/post/' + @data[:tmp_post]["id"].to_s + '/comment', :params => {
        :body => 'Admin',
    }, :headers => {:Authorization => @data[:admin_jwt]}
    @data[:a_comment] = JSON.parse(response.body)["comment"]
    expect(response).to have_http_status(200)
  end
  it "Reply Comment | User delete" do
    post '/api/v1/comment/' + @data[:a_comment]["id"].to_s + '/reply', :params => {
        :body => 'John-a<<',
    }, :headers => {:Authorization => @data[:john]["token"]}
    @data[:b_comment] = JSON.parse(response.body)["comment"]
    expect(response).to have_http_status(200)
  end
  it "Reply Comment | Simple delete" do
    post '/api/v1/comment/' + @data[:b_comment]["id"].to_s + '/reply', :params => {
        :body => 'Alex',
    }, :headers => {:Authorization => @data[:alex]["token"]}
    @data[:d_comment] = JSON.parse(response.body)["comment"]
    expect(response).to have_http_status(200)
  end
  it "Reply Comment | Cascade delete" do
    post '/api/v1/comment/' + @data[:d_comment]["id"].to_s + '/reply', :params => {
        :body => 'John-b<<',
    }, :headers => {:Authorization => @data[:john]["token"]}
    expect(response).to have_http_status(200)
    debug_print_comments(stage: 'Comments for links test')
  end
  it "Comment Delete | Casscade" do
    delete '/api/v1/comment/' + @data[:d_comment]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(200)
    debug_print_comments(stage: 'Deleted Alex & Last John')
  end
  it "User delete | Comments remove" do
    delete '/api/v1/user/' + @data[:john]["user"]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
    debug_print_comments(stage: 'Deleted John')
  end
  it "Post Delete" do
    delete '/api/v1/post/' + @data[:tmp_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
    expect(response).to have_http_status(200)
    debug_print_comments(stage: 'Deleted Main post and comments')
  end
end

