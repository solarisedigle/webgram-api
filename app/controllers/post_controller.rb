class PostController < ApplicationController
    def create
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            post = Post.new
            post.title = params[:title]
            post.image = params[:image]
            post.body = !params[:body].nil? ? CGI.escapeHTML(params[:body]) : ''
            post.category = Category.find(params[:category])
            if(User.find(@user["id"]).posts << post)
                if !params[:tags].nil? && params[:tags].kind_of?(Array)
                    for tagname in params[:tags] do
                        tag = Tag.find_or_create_by(name: tagname.downcase)
                        if !tag.save()
                            result[:success] = false
                            statuscode = 203
                            if result[:errors].nil?
                                result[:errors] = []
                            end
                            result[:errors].push(tag.errors)
                        else
                            post.tags << tag
                            if result[:tags].nil?
                                result[:tags] = []
                            end
                            result[:tags].push(tag)
                        end
                    end
                end
                result[:post] = post
            else
                result = {:success => false, :errors=> post.errors}
                statuscode = 422
            end
        else
            result = {:error => "Only authenticated users can create posts"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def delete
        statuscode = 200
        result = {:success => true}
        post = Post.where(id: params[:id])
        if post.length > 0
            if (post[0].user == @user || @user["role"] == "admin")                
                if !post[0].destroy()
                    result = {:error => "Fatal server error: Post " + params[:id] + " destroy"}
                    statuscode = 500
                end
            else
                result = {:error => "Only author or admin can delete the post"}
                statuscode = 403
            end
        else
            result = {:error => "Fatal error: Post " + params[:id] + " not found"}
            statuscode = 404
        end
        render json: result, status: statuscode
    end
    def like
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            post = Post.where(id: params[:id])
            if post.length > 0
                if Like.find_by(user: @user, post: post[0]).nil?
                    like = Like.new()
                    like.user = @user
                    like.post = post[0]
                    if like.save()
                        result = {:success => true}
                        statuscode = 200
                    else
                        result = {:error => "Fatal server error: Like"}
                        statuscode = 500
                    end
                else
                    result = {:success => false, :error => "Like already exists"}
                    statuscode = 205
                end
            else
                result = {:error => "Fatal error: Post " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can rate the post"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def dislike
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            post = Post.where(id: params[:id])
            if post.length > 0
                if !(like = Like.find_by(user: @user, post: post[0])).nil?
                    if !like.destroy()
                        result = {:error => "Fatal server error: dislike"}
                        statuscode = 500
                    end
                else
                    result = {:success => false, :error => "Like already doen't exists"}
                    statuscode = 205
                end
            else
                result = {:error => "Fatal error: Post " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can rate the post"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
end
