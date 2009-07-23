class NetworksController < ApplicationController
  
  before_filter :load_user
  
  def show
    load_connected_installs
  end
  
  def in_common
    load_connected_installs do |apps_vs_connected_installs|
      apps_vs_connected_installs.reject! { |app, installs| !@user.apps.include?(app) }
    end
    render :action => 'show'
  end
  
  def not_in_common
    load_connected_installs do |apps_vs_connected_installs|
      apps_vs_connected_installs.reject! { |app, installs| @user.apps.include?(app) }
    end
    render :action => 'show'
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id], :include => { :installs => :app })
  end
  
  def load_connected_installs
    apps_vs_connected_installs = (@user.installs(:include => :app) + @user.connected_installs(:include => :app)).group_by(&:app).sort_by { |app, installs| -installs.length }
    yield apps_vs_connected_installs if block_given?
    @connected_installs = apps_vs_connected_installs.paginate(:page => params[:page], :per_page => 15)
  end
  
end