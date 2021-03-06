class AppsController < ApplicationController
  
  before_filter :has_rss_feed, :only => [:recent]
  caches_action :recent, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  
  # no expiry yet
  caches_action :popular, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  caches_action :rated, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  caches_action :summary, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  
  def show
    @app = App.find_by_identifier(params[:id])
    unless @app
      @app = App.find(params[:id])
      redirect_to app_path(@app), :status => :moved_permanently
      return
    end
    @events = @app.events.paginate(:order => 'created_at DESC, purchased_at DESC', :page => params[:page], :per_page => 10)
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