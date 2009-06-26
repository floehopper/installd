class UsersController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:id])
    @installs = @user.installs.paginate(:include => :app, :page => params[:page], :per_page => 10)
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
