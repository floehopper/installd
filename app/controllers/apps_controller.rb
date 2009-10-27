class AppsController < ApplicationController
  
  def show
    @app = App.find_by_identifier(params[:id])
    unless @app
      @app = App.find(params[:id])
      redirect_to app_path(@app), :status => :moved_permanently
      return
    end
    @events = @app.events.paginate(:order => 'created_at DESC', :page => params[:page], :per_page => 10)
  end
  
  def summary
    @recent_apps = App.all(:include => { :events => :user }, :order => 'created_at DESC', :limit => 5)
    @popular_apps = App.popular(:limit => 5)
    @rated_apps = App.rated(:limit => 5)
  end
  
  def recent
    @apps = App.paginate(:all, :include => { :events => :user }, :order => 'created_at DESC', :page => params[:page], :per_page => 15)
  end
  
  def popular
    @apps = App.popular.paginate(:page => params[:page], :per_page => 15)
  end
  
  def rated
    @apps = App.rated.paginate(:page => params[:page], :per_page => 15)
  end
  
end