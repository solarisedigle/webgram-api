class CommentController < ApplicationController
    def create
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            post = Post.where(id: params[:id])
            if post.length > 0
                comment = Comment.new()
                comment.user = @user
                comment.body = !params[:body].nil? ? CGI.escapeHTML(params[:body]) : ''
                if(post[0].comments << comment)
                    result = {:success => true, :comment=> comment}
                    statuscode = 200
                else
                    result = {:success => false, :errors=> comment.errors}
                    statuscode = 422
                end
            else
                result = {:error => "Fatal error: Comment " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can comment"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def reply
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            comment = Comment.where(id: params[:id])
            if comment.length > 0
                reply = Comment.new()
                reply.user = @user
                reply.post = comment[0].post
                reply.body = !params[:body].nil? ? CGI.escapeHTML(params[:body]) : ''
                if(comment[0].replies << reply)
                    result = {:success => true, :comment=> reply}
                    statuscode = 200
                else
                    result = {:success => false, :errors=> reply.errors}
                    statuscode = 422
                end
            else
                result = {:error => "Fatal error: Comment " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can comment"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def delete
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "user" || @user["role"] == "admin")
            comment = Comment.where(id: params[:id])
            if comment.length > 0
                if (comment[0].user == @user || @user["role"] == "admin")                
                    if !comment[0].destroy()
                        result = {:error => "Fatal server error: Comment " + params[:id] + " destroy"}
                        statuscode = 500
                    end
                else
                    result = {:error => "Only author or admin can delete the comment"}
                    statuscode = 403
                end
            else
                result = {:error => "Fatal error: Comment " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only registered user can comment"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
end
