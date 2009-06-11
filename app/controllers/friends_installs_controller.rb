class FriendsInstallsController < ApplicationController
  
  def index
    @user = User.find_by_login(params[:user_id])
    @friends_installs = @user.friends_installs.paginate(:include => :app, :page => params[:page], :per_page => 10)
  end
  
end