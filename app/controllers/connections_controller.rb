class ConnectionsController < ApplicationController
  
  def new
    @connected_user = User.find_by_login(params[:user_id])
    @connection = Connection.new(:user => current_user, :connected_user => @connected_user)
  end
  
  def create
    @connected_user = User.find_by_login(params[:user_id])
    @connection = Connection.new(:user => current_user, :connected_user => @connected_user)
    if params[:commit] == 'Yes'
      if @connection.save
        flash[:notice] = "#{@connected_user.login} has been added to your network."
        redirect_to @connected_user
      else
        flash[:notice] = "Failed to add #{@connected_user.login} from your network."
        render :action => 'new'
      end
    else
      flash[:notice] = nil
      redirect_to @connected_user
    end
  end
  
  def delete
    @connected_user = User.find_by_login(params[:user_id])
  end
  
  def destroy
    @connected_user = User.find_by_login(params[:user_id])
    @connection = current_user.connections.find_by_connected_user_id(@connected_user.id)
    if params[:commit] == 'Yes'
      if @connected_user && @connection && @connection.destroy
        flash[:notice] = "#{@connected_user.login} has been removed from your network."
        redirect_to @connected_user
      else
        flash[:notice] = "Failed to remove #{@connected_user.login} from your network."
        render :action => 'new'
      end
    else
      flash[:notice] = nil
      redirect_to @connected_user
    end
  end
  
end