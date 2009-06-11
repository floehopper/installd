class UsersController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:id])
    @installs = @user.installs.all(:include => :app)
    @friends_installs = @user.friends_installs.all(:include => :app)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Registration was successful.'
      redirect_to @user
    else
      render :action => 'new'
    end
  end
  
end
