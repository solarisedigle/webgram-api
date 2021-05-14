require 'rails_helper'
def debug_print_posts (stage: 'S')
    Rails.logger.debug "\n---Posts " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Post.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
RSpec.describe 'File upload tests', :type => :request do
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
    it "Category Create" do
        post '/api/v1/category', :params => {
            :name => @defaults[:categories][0][:name],
            :description => @defaults[:categories][0][:description],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        @data[:tmp_category] = JSON.parse(response.body)["category"]
        expect(response).to have_http_status(200)
    end
    it "Post Create | Fake format" do
        post '/api/v1/post', :params => {
            :title => 'New post',
            :body => @defaults[:posts][0][:body],
            :image => fixture_file_upload('test.svg', 'image/svg'),
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(422)
    end
    it "Post Create | Large file" do
        post '/api/v1/post', :params => {
            :title => 'New post',
            :body => @defaults[:posts][0][:body],
            :image => fixture_file_upload('test8.jpg', 'image/jpeg'),
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(413)
    end
    it "Post Create | Fake file" do
        post '/api/v1/post', :params => {
            :title => 'New post',
            :body => @defaults[:posts][0][:body],
            :image => fixture_file_upload('testF.jpg', 'image/jpeg'),
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(409)
    end
    it "Post Create | Image upload" do
        post '/api/v1/post', :params => {
            :title => 'New post',
            :body => @defaults[:posts][0][:body],
            :image => fixture_file_upload('test.jpg', 'image/jpeg'),
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        @data[:tmp_post] = JSON.parse(response.body)["post"]
        debug_print_posts(stage: 'Image uploaded')
        expect(response).to have_http_status(200)
    end
    it "Post Delete | Image delete" do
        delete '/api/v1/post/' + @data[:tmp_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
    end
end

