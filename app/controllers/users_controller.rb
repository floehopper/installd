class UsersController < ApplicationController
  
  def lookup
    flash[:notice] = nil
    if login = params[:login]
      @user = User.find_by_login(params[:login])
      if @user
        redirect_to user_path(@user)
      else
        flash[:notice] = 'No user found.'
      end
    end
  end
  
  def show
    @user = User.find_by_login(params[:id])
    @installs = @user.installs.paginate(:include => :app, :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    @rss_feed_url = user_url(@user, :format => 'rss')
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
      flash[:notice] = 'Registration failed.'
      render :action => 'new'
    end
  end
  
end
