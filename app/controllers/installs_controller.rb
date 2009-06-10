class InstallsController < ApplicationController
  
  before_filter :load_user, :only => [:index, :create, :new]
  
  def index
    if @user
      @installs = @user.installs.find(:all)
    else
      @installs = Install.find(:all)
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @installs }
    end
  end
  
  def show
    @install = Install.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @install }
    end
  end
  
  def new
    if @user
      @install = @user.installs.build
    else
      @install = Install.new
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @install }
    end
  end
  
  def edit
    @install = Install.find(params[:id])
  end
  
  def create
    if @user
      @install = @user.installs.build(params[:install])
    else
      @install = Install.new(params[:install])
    end
    
    respond_to do |format|
      if @install.save
        flash[:notice] = 'Install was successfully created.'
        format.html { redirect_to(@install) }
        format.xml  { render :xml => @install, :status => :created, :location => @install }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @install.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @install = Install.find(params[:id])
    
    respond_to do |format|
      if @install.update_attributes(params[:install])
        flash[:notice] = 'Install was successfully updated.'
        format.html { redirect_to(@install) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @install.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @install = Install.find(params[:id])
    @install.destroy
    
    respond_to do |format|
      format.html { redirect_to(installs_url) }
      format.xml  { head :ok }
    end
  end
  
    private
    
    def load_user
      if params[:user_id]
        @user = User.find(params[:user_id])
      end
    end
    
end