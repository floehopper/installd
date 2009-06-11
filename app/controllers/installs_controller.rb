class InstallsController < ApplicationController
  
  def index
    @user = User.find_by_login(params[:user_id])
    @installs = @user.installs.paginate(:include => :app, :page => params[:page], :per_page => 10)
  end
    
end
