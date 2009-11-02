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
    sync_session = nil
    user = User.find_by_login(params[:user_id])
    if user
      sync_session = user.sync_sessions.create!(:raw_xml => params[:doc])
      if user == current_user
        sync_session.send_later(:parse)
        render :nothing => true, :status => :ok
      else
        sync_session.update_attributes(:status => 'forbidden')
        render :nothing => true, :status => :forbidden
      end
    else
      render :nothing => true, :status => :not_found
    end
  rescue => e
    sync_session.update_attributes(:status => "exception: #{e}") if sync_session
    raise e
  end
  
end
