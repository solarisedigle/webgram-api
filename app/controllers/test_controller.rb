class TestController < ApplicationController
    def index
        puts "This works"
        render json: {
            :headers => headers, 
            :params => params,
            :session => session,
            :debug => @user
        }
    end
end
