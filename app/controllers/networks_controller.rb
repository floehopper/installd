class NetworksController < ApplicationController
  
  before_filter :load_user
  
  def show
    @apps = @user.connected_apps_including_mine.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
  end
  
  def in_common
    @apps = @user.connected_apps_in_common.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  def not_in_common
    @apps = @user.connected_apps_not_in_common.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id])
  end
  
end