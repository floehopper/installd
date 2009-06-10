class UsersController < ApplicationController
  
  before_filter :require_no_user, :only => [:index, :new, :create]
  before_filter :require_user, :except => [:index, :new, :create]
  # before_filter :load_app, :only => [:index, :new, :create]
  
  def index
    login = params[:login]
    if login
      @users = User.find_all_by_login(login)
    else
      @users = User.find(:all)
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @user = @current_user
  end
  
  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  private
  
    def load_app
      if params[:app_id]
        @app = App.find(params[:app_id])
      end
    end
  
end
