class GeneralController < ApplicationController
    def delete_category
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin")
            category = Category.where(id: params[:id])
            if category.length > 0
                if !category[0].destroy()
                    result = {:error => "Fatal server error: Category " + params[:id] + " destroy"}
                    statuscode = 500
                end
            else
                result = {:error => "Fatal error: Category " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only admin can delete the category"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def create_category
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin")
            category = Category.new
            category.name = params[:name]
            category.description =  !params[:description].nil? ? CGI.escapeHTML(params[:description]) : ''
            if !category.save
                statuscode = 422
                result = {:success => false, :errors=> category.errors}
            else
                result[:category] = category
            end
        else
            result = {:error => "Only admin can create the category"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def delete_tag
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin")
            tag = Tag.where(id: params[:id])
            if tag.length > 0
                if !tag[0].destroy()
                    result = {:error => "Fatal server error: Category " + params[:id] + " destroy"}
                    statuscode = 500
                end
            else
                result = {:error => "Fatal error: Category " + params[:id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only admin can delete the category"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
    def delete_tag_post
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin")
            tag_post = TagPost.where(tag_id: params[:tag_id], post_id: params[:post_id])
            if tag_post.length > 0
                if !tag_post[0].destroy()
                    result = {:error => "Fatal server error: TagPost " + params[:tag_id] + '/' + params[:posy_id] + " destroy"}
                    statuscode = 500
                end
            else
                result = {:error => "Fatal error: TagPost " + params[:tag_id] + '/' + params[:posy_id] + " not found"}
                statuscode = 404
            end
        else
            result = {:error => "Only admin can delete the category"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
end
