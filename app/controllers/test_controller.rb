class TestController < ApplicationController
    def index
        render json: {
            :headers => headers, 
            :session => session,
            :debug => @user,
            :categories => Category.all,
            :users => User.all,
            :posts => Post.all.order('count_of_likes DESC NULLS LAST'),
            :likes => Like.all,
            :tags => Tag.all,
            :tagsposts => TagPost.all,
            :comments => Comment.all,
        }, status: 200
    end
end
