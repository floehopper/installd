class ReviewsController < ApplicationController
  
  def create
    review = Review.new(params[:review])
    if review.user == current_user
      review.save
    end
    respond_to do |format|
     format.js { render :nothing => true }
     format.html { redirect_to :back }
    end
  end
  
  def update
    review = Review.find(params[:id])
    if review && review.user == current_user
      rating = params[:review] && params[:review][:rating]
      review.update_attributes(:rating => rating)
    end
    respond_to do |format|
     format.js { render :nothing => true }
     format.html { redirect_to :back }
    end
  end
  
end