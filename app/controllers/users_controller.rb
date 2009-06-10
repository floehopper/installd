class UsersController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to @user
    else
      render :action => 'new'
    end
  end
  
end
