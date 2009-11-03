class ConnectionsController < ApplicationController
  
  before_filter :require_user
  before_filter :load_user
  before_filter :require_authorized_user
  
  before_filter :load_connection, :only => [:delete, :destroy]
  before_filter :require_connection, :only => [:delete, :destroy]
  before_filter :require_user_to_own_connection, :only => [:delete, :destroy]
  
  def new
    connected_user = User.find_by_login(params[:connected_user_id])
    if connected_user
      unless @user.already_connected?(connected_user)
        @connection = @user.connections.build(:connected_user => connected_user)
      else
        flash[:notice] = "#{connected_user.login} is already in your network"
        redirect_to connected_user
      end
    else
      flash[:notice] = "#{params[:connected_user_id]} was not found"
      redirect_to @user
    end
  end
  
  def create
    @connection = Connection.new(params[:connection])
    if params[:commit] == 'Yes'
      if @connection.save
        flash[:notice] = "#{@connection.connected_user.login} has been added to your network."
        redirect_to @connection.connected_user
      else
        flash[:notice] = "Failed to add #{@connected_user.login} to your network."
        render :action => 'new'
      end
    else
      flash[:notice] = nil
      redirect_to @connection.connected_user
    end
  end
  
  def delete
    render
  end
  
  def destroy
    if params[:commit] == 'Yes'
      if @connection.destroy
        flash[:notice] = "#{@connection.connected_user.login} has been removed from your network."
        redirect_to @connection.connected_user
      else
        flash[:notice] = "Failed to remove #{@connection.connected_user.login} from your network."
        render :action => 'delete'
      end
    else
      flash[:notice] = nil
      redirect_to @connection.connected_user
    end
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id])
  end
  
  def require_authorized_user
    unless @user == current_user
      flash[:notice] = 'You can only manage users in your own network.'
      redirect_to @user
    end
  end
  
  def load_connection
    @connection = Connection.find(params[:id])
  end
  
  def require_connection
    unless @connection
      flash[:notice] = 'Cannot find connection to remove.'
      redirect_to @user
    end
  end
  
  def require_user_to_own_connection
    unless @connection.user == @user
      flash[:notice] = 'You can only manage users in your own network.'
      redirect_to @connection.connected_user
    end
  end
  
end