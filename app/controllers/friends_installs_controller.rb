class FriendsInstallsController < ApplicationController
  
  def index
    @user = User.find_by_login(params[:user_id])
    @friends_installs = @user.friends_installs.all(:include => :app)
  end
  
end