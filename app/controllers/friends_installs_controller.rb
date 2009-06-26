class FriendsInstallsController < ApplicationController
  
  def index
    @user = User.find_by_login(params[:user_id])
    apps_vs_friends_installs = @user.friends_installs(:include => :app).group_by(&:app).sort_by { |app, installs| -installs.length }
    @friends_installs = apps_vs_friends_installs.paginate(:page => params[:page], :per_page => 10)
  end
  
end