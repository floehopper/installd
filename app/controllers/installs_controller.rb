class InstallsController < ApplicationController
  
  def index
    @user = User.find_by_login(params[:user_id])
    @installs = @user.installs.all(:include => :app)
  end
    
end
