class UsersController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:id])
    @installs = @user.installs.paginate(:include => :app, :page => params[:page], :per_page => 10)
    @connected_users = @user.connected_users
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.deliver_registration(@user)
      flash[:notice] = 'Registration successful.'
      redirect_to root_path
    else
      render :action => 'new'
    end
  end
  
end
