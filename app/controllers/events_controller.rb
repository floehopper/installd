class EventsController < ApplicationController
  
  ssl_required :synchronize
  
  def index
    user_id = params[:user_id]
    if user_id
      @user = User.find_by_login(user_id)
      @events = @user.events.paginate(:include => [:app, :user], :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    else
      @events = Event.paginate(:all, :include => [:app, :user], :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    end
  end
  
  def synchronize
    user = User.find_by_login(params[:user_id])
    if current_user && (current_user == user)
      sync = user.syncs.create!
      parser = IphoneAppPlistParser.new(params[:doc])
      user.synchronize(parser, sync)
      status = :ok
    else
      status = :forbidden
    end
  rescue
    status = :internal_server_error
  ensure
    sync.update_attributes(:status => status.to_s)
    render :nothing => true, :status => status
  end
  
end
