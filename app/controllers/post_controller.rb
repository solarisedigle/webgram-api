class PostController < ApplicationController
    def create
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            post = Post.new
            post.title = params[:title]
            tmp_upload = ''
            if !params[:image].nil?
                if (params[:image].is_a?(ActionDispatch::Http::UploadedFile) && (params[:image].content_type == "image/jpeg" || params[:image].content_type == "image/png"))
                    if params[:image].size < 7.megabytes
                        begin
                            tmp_upload = Cloudinary::Uploader.upload(params[:image], options = {})
                        rescue CloudinaryException
                            render(json: {:success => false, :errors => {:image => "image upload failed"}}, status: 409) and return
                        end
                        post.image = tmp_upload["secure_url"]
                    else
                        render(json: {:success => false, :errors => {:image => "image size must be less than 7 Mb"}}, status: 413) and return
                    end
                else
                    render(json: {:success => false, :errors => {:image => "supports only jpeg and png formats"}}, status: 422) and return
                end
            end
            post.body = !params[:body].blank? ? CGI.escapeHTML(params[:body]) : ''
            post.category = Category.find(params[:category])
            if(User.find(@user["id"]).posts << post)
                if !params[:tags].blank?
                    tags_list = []
                    if params[:tags].kind_of?(Array)
                        tags_list = params[:tags]
                    elsif params[:tags].kind_of?(String) 
                        tags_list = params[:tags].split(',')
                    end
                    for tagname in tags_list do
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
                if(tmp_upload && tmp_upload != '')
                    Cloudinary::Uploader.destroy(tmp_upload["public_id"], options = {})
                end
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
                        return check_like
                    else
                        result = {:error => "Fatal server error: Like"}
                        statuscode = 500
                    end
                else
                    result = like_info()
                    statuscode = 200
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
                    if like.destroy()
                        return check_like
                    else
                        result = {:error => "Fatal server error: dislike"}
                        statuscode = 500
                    end
                else
                    result = like_info()
                    statuscode = 200
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
    def like_info
        like = Like.where(post_id: params[:id], user_id: @user["id"])
        return {:isset => like.length, :summ => Like.where(post_id: params[:id]).length}
    end
    def check_like
        render json: like_info(), status: 200
    end
    def get_by
        request = []
        if !params[:user].blank? 
            request.push("(user_id = #{params[:user]})")
        end
        if !params[:users].blank?
            if params[:users] == 'only_subscriptions' && @user[:role] != 'guest'
                users_needed = []
                for user in @user.follows do
                    users_needed.push(user["id"])
                end
                if users_needed.length == 0
                    render(json: {posts: [], general: 0}, status: 200) and return
                end
                request.push("(user_id in (#{users_needed.join(',')}))")
            end 
        end
        if !params[:tag].blank?
            tag = Tag.where(:name => params[:tag])
            if tag.length == 0
                render(json: {posts: [], general: 0}, status: 200) and return
            end
            tag_posts = TagPost.where(:tag_id => tag[0]["id"])
            if tag_posts.length == 0
                render(json: {posts: [], general: 0}, status: 200) and return
            end
            posts_fit = []
            for tag_post in tag_posts do
                posts_fit.push(tag_post["post_id"])
            end
            request.push("(id in (#{posts_fit.join(',')}))")
        end
        if (!params[:category].blank? && params[:category].to_i > 0)
            request.push("(category_id = #{params[:category]})")
        end
        if !params[:text].blank? 
            search_text = CGI.escapeHTML(params[:text]).downcase;
            request.push("(lower(title) like '%#{search_text}%' OR lower(body) like '%#{search_text}%')")
        end

        requset = request.join('AND')
        posts = Post.where(requset)
            .offset(params[:offset].nil? ? 0 : params[:offset])
            .limit(params[:limit].nil? ? 10 : params[:limit])
            .includes([:user, {comments: [:user]}, :tags, :category])
            .order(params[:order].nil? ? 'created_at desc' : (params[:order] + ' NULLS LAST, created_at DESC'))
        formed_posts = []
        for post in posts do
            post_obj = {
                :post => post,
                :user => post.user.main_data,
                :comments => [],
                :category => post.category.name,
                :tags => post.tags
            }
            for comment in post.comments do
                post_obj[:comments].push(comment.main_data)
            end
            formed_posts.push(post_obj)
        end
        render json: {posts: formed_posts, general: Post.where(requset).count}, status: 200
    end
end
