class GeneralController < ApplicationController
    def delete_category
        statuscode = 200
        result = {:success => true}
        if (@user["role"] == "admin")
            category = Category.where(id: params[:id])
            if category.length > 0
                if !category[0].destroy()
                    statuscode = 500
                    result = {:error => "Fatal server error: Category " + params[:id] + " destroy"}
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
            end
        else
            result = {:error => "Only admin can create the category"}
            statuscode = 403
        end
        render json: result, status: statuscode
    end
end
