class TestController < ApplicationController
    def index
        render json: {
            :headers => headers, 
            :params => params,
            :session => session,
            :debug => @user
        }, status: 200
    end
end
