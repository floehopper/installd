class ConnectionsController < ApplicationController
  
  def new
    @connected_user = User.find_by_login(params[:user_id])
    @connection = Connection.new(:user => current_user, :connected_user => @connected_user)
  end
  
  def create
    @connected_user = User.find_by_login(params[:user_id])
    @connection = Connection.new(:user => current_user, :connected_user => @connected_user)
    if @connection.save
      flash[:notice] = "#{@connected_user.login} has been added to your network."
      redirect_to @connected_user
    else
      render :action => 'new'
    end
  end
  
end