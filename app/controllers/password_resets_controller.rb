class PasswordResetsController < ApplicationController
  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  
  def new
    render
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset!
      flash[:notice] = "Instructions to reset your password have been emailed to you."
      redirect_to root_url
    else
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end
  
  def edit
    render
  end
  
  def update
    @user.password = params[:user][:password]
    if @user.save
      flash[:notice] = "Password successfully updated"
      redirect_to root_url
    else
      render :action => :edit
    end
  end
  
  private
  
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account."
      redirect_to root_url
    end
  end
  
end
