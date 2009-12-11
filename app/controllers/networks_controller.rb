class NetworksController < ApplicationController
  
  before_filter :load_user_and_connected_users
  before_filter :has_rss_feed, :only => [:show, :in_common, :not_in_common]
  
  # no expiry yet
  caches_action :show, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  caches_action :in_common, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  caches_action :not_in_common, :layout => false, :cache_path => Proc.new { |controller| controller.params.slice(:page) }
  
  def show
    @title = "#{@user.login}'s Network - All"
    @apps = @user.connected_apps_including_mine.paginate(:page => params[:page], :per_page => 10)
  end
  
  def in_common
    @title = "#{@user.login}'s Network - In Common"
    @apps = @user.connected_apps_in_common.paginate(:page => params[:page], :per_page => 10)
    render :action => 'show'
  end
  
  def not_in_common
    @title = "#{@user.login}'s Network - Not In Common"
    @apps = @user.connected_apps_not_in_common.paginate(:page => params[:page], :per_page => 10)
    render :action => 'show'
  end
  
  private
  
  def load_user_and_connected_users
    @user = User.find_by_login(params[:user_id])
    @connected_users = @user.connected_users.find(:all, :order => 'login')
    @inbound_connected_users = @user.inbound_connected_users.find(:all, :order => 'login')
  end
  
end