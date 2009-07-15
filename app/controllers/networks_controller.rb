class NetworksController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:user_id], :include => { :installs => :app })
    apps_vs_friends_installs = @user.friends_installs(:include => :app).group_by(&:app).sort_by { |app, installs| -installs.length }
    @friends_installs = apps_vs_friends_installs.paginate(:page => params[:page], :per_page => 10)
  end
  
  def in_common
    @user = User.find_by_login(params[:user_id], :include => { :installs => :app })
    apps_vs_friends_installs = @user.friends_installs(:include => :app).group_by(&:app).sort_by { |app, installs| -installs.length }
    apps_vs_friends_installs.reject! { |app, installs| !@user.apps.include?(app) }
    @friends_installs = apps_vs_friends_installs.paginate(:page => params[:page], :per_page => 10)
    render :action => 'show'
  end
  
  def not_in_common
    @user = User.find_by_login(params[:user_id], :include => { :installs => :app })
    apps_vs_friends_installs = @user.friends_installs(:include => :app).group_by(&:app).sort_by { |app, installs| -installs.length }
    apps_vs_friends_installs.reject! { |app, installs| @user.apps.include?(app) }
    @friends_installs = apps_vs_friends_installs.paginate(:page => params[:page], :per_page => 10)
    render :action => 'show'
  end
  
end