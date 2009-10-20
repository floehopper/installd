class NetworksController < ApplicationController
  
  before_filter :load_user_and_connected_users
  
  def show
    @apps = @user.connected_apps_including_mine.paginate(:page => params[:page], :per_page => 10)
  end
  
  def in_common
    @apps = @user.connected_apps_in_common.paginate(:page => params[:page], :per_page => 10)
    render :action => 'show'
  end
  
  def not_in_common
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