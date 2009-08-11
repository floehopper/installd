class NetworksController < ApplicationController
  
  before_filter :load_user
  
  def show
    my_apps = Set.new(@user.apps)
    network_apps = Set.new(@user.connected_installs(:include => :app).map(&:app))
    now = Time.now
    @apps = (network_apps + my_apps).sort_by { |app| now - app.installs.map(&:created_at).max }.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
  end
  
  def in_common
    my_apps = Set.new(@user.apps)
    network_apps = Set.new(@user.connected_installs(:include => :app).map(&:app))
    now = Time.now
    @apps = (network_apps & my_apps).sort_by { |app| now - app.installs.map(&:created_at).max }.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  def not_in_common
    my_apps = Set.new(@user.apps)
    network_apps = Set.new(@user.connected_installs(:include => :app).map(&:app))
    now = Time.now
    @apps = (network_apps - my_apps).sort_by { |app| now - app.installs.map(&:created_at).max }.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id], :include => { :installs => :app })
  end
  
end