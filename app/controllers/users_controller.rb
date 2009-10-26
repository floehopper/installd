class UsersController < ApplicationController
  
  before_filter :require_floehopper, :only => [:index, :invite]
  
  def index
    @users = User.paginate(:order => 'active, updated_at', :page => params[:page], :per_page => 10)
  end
  
  def invite
    @user = User.find(params[:id])
    @user.invite!
    redirect_to users_path
  end
  
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
    @apps = @user.installed_apps(:include => { :installs => :user }, :order => 'created_at DESC').paginate(:page => params[:page], :per_page => 15)
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
  
  private
  
    def require_floehopper
      unless current_user && current_user.login == 'floehopper'
        redirect_to root_path
      end
    end
  
end
