class RecipesController < ApplicationController
    before_action :authorize
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

    def index
        recipes=Recipe.all 
        render json: recipes, include: :user, status: :created
    end

    def create
        if session[:user_id]
            user=User.find_by(id:[session[:user_id]])
            recipe=user.recipes.create!(recipe_params)
            render json: recipe, include: :user, status: :created
        else
            render json: {errors:["Not logged in."]}, status: :unauthorized
        end
    end

    private

    def authorize
        return render json: {errors: ["Not authorized."]}, status: :unauthorized unless session.include? :user_id
    end

    def recipe_params
        params.permit(:title, :instructions, :minutes_to_complete)
    end

    def render_unprocessable_entity_response(invalid)
        render json: { errors: [invalid.record.errors] }, status: :unprocessable_entity
    end

end
