class TestController < ApplicationController
    def index
        render json: {
            :headers => headers, 
            :params => params,
            :session => session,
            :debug => @user,
            :categories => Category.all,
            :users => User.all,
            :posts => Post.all,
            :likes => Like.all,
            :tags => Tag.all,
            :tagsposts => TagPost.all,
            :comments => Comment.all,
        }, status: 200
    end
end
