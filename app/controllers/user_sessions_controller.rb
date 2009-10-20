class UserSessionsController < ApplicationController
  
  ssl_required :new
  ssl_allowed :create
  
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => [:delete, :destroy]
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_to @user_session.user
    else
      render :action => 'new'
    end
  end
  
  def delete
    @user_session = current_user_session
  end
  
  def destroy
    @user_session = current_user_session
    
    if params[:commit] == 'Yes'
      @user_session.destroy
      flash[:notice] = "Logout successful!"
      redirect_to new_user_session_url
    else
      redirect_to account_url
    end
  end
  
end
