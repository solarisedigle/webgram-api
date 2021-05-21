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
def debug_print_tags (stage: 'S')
    Rails.logger.debug "\n---Tags / links " + stage + "\n"
    Rails.logger.debug JSON.pretty_generate(Tag.all.map(&:attributes))
    Rails.logger.debug JSON.pretty_generate(TagPost.all.map(&:attributes))
    Rails.logger.debug "\n---/" + stage + "\n"
end
RSpec.describe 'Tags tests', :type => :request do
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
    it "Post Create | Wrong tags" do
        post '/api/v1/post', :params => {
            :title => 'Wrong tags post',
            :body => @defaults[:posts][0][:body],
            :tags => ['webgram--api', 'good-taG', 'tes'],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        Rails.logger.debug "\n---Wrong tags " + JSON.pretty_generate(JSON.parse(response.body))
        expect(response).to have_http_status(203)
        @data[:tmp_wrong_post] = JSON.parse(response.body)["post"]
    end
    it "Post Create | With tags" do
        post '/api/v1/post', :params => {
            :title => 'Last tag post',
            :body => @defaults[:posts][0][:body],
            :tags => ['WebgraM', 'webgram-api', 'test'],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        @data[:tmp_post] = JSON.parse(response.body)["post"]
    end
    it "Post Create | Existed tags" do
        post '/api/v1/post', :params => {
            :title => 'Existed tags post',
            :body => @defaults[:posts][0][:body],
            :tags => ['webgram', 'test'],
            :category => @data[:tmp_category]["id"],
        }, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        @data[:tmp_second_post] = JSON.parse(response.body)["post"]
        debug_print_posts(stage: 'Posts created')
        debug_print_tags(stage: 'Tags created')
        @data[:tmp_tag] = JSON.parse(response.body)["tags"][0]
        @data[:tmp_last_tag] = JSON.parse(response.body)["tags"][1]
    end
    it "TagPost Delete | After post" do
        delete '/api/v1/post/' + @data[:tmp_wrong_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Wrong post deleted')
        debug_print_tags(stage: 'Deleted good-tag LINK after wrong post')
    end
    it "Tag Delete | Permission error" do
        delete '/api/v1/tag/' + @data[:tmp_tag]["id"].to_s
        expect(response).to have_http_status(403)
    end
    it "Tag Delete | Fake tag" do
        delete '/api/v1/tag/-1', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "TagPost Delete | After tag" do
        delete '/api/v1/tag/' + @data[:tmp_tag]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_tags(stage: 'Deleted webgram tag LINK after webgram tag')
    end
    it "Tag Delete | After last post" do
        delete '/api/v1/post/' + @data[:tmp_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Last webgram-api post deleted')
        debug_print_tags(stage: 'Deleted webgram-api Tag after webgram-api last link delete')
    end
    it "TagPost Delete | Permission error" do
        delete '/api/v1/tag/' + @data[:tmp_last_tag]["id"].to_s + '/post/' + @data[:tmp_second_post]["id"].to_s
        expect(response).to have_http_status(403)
    end
    it "TagPost Delete | Fake TagPost" do
        delete '/api/v1/tag/-1/', :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(404)
    end
    it "TagPost Delete | With tag" do
        delete '/api/v1/tag/' + @data[:tmp_last_tag]["id"].to_s + '/post/' + @data[:tmp_second_post]["id"].to_s, :headers => {:Authorization => @data[:admin_jwt]}
        expect(response).to have_http_status(200)
        debug_print_posts(stage: 'Last post deleted')
        debug_print_tags(stage: 'Deleted test TagPost and test Tag after last post delete')
    end
end

