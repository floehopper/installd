class AppsController < ApplicationController
  
  before_filter :load_user, :only => [:index]
  
  # GET /apps
  # GET /apps.xml
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
      format.html # index.html.erb
      format.xml  { render :xml => @apps }
    end
  end
  
  private
  
    def load_user
      if params[:user_id]
        @user = User.find(params[:user_id])
      end
    end
  
end