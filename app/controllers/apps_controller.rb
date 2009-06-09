class AppsController < ApplicationController
  
  before_filter :require_user, :except => [:index, :show]
  before_filter :load_app, :only => [:show, :edit, :update, :destroy]
  # before_filter :load_user, :only => [:index, :new, :create]
  
  def index
    if @user
      @apps = @user.apps.find(:all)
    else
      name = params[:name]
      if name
        @apps = App.find_all_by_name(name)
      else
        @apps = App.find(:all)
      end
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @apps }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @app }
    end
  end
  
  def new
    if @user
      @app = @user.apps.build
    else
      @app = App.new
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @app }
    end
  end
  
  def edit
  end
  
  def create
    if @user
      @app = @user.apps.build(params[:app])
    else
      @app = App.new(params[:app])
    end
    
    respond_to do |format|
      if @app.save
        flash[:notice] = 'App was successfully created.'
        format.html { redirect_to(@app) }
        format.xml  { render :xml => @app, :status => :created, :location => @app }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @app.update_attributes(params[:app])
        flash[:notice] = 'App was successfully updated.'
        format.html { redirect_to(@app) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @app.destroy
    
    respond_to do |format|
      format.html { redirect_to(apps_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
    def load_app
      if params[:id]
        @app = App.find(params[:id])
      end
    end
    
    def load_user
      if params[:user_id]
        @user = User.find(params[:user_id])
      end
    end

end