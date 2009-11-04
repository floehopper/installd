class EventsController < ApplicationController
  
  ssl_required :synchronize
  
  before_filter :load_user
  
  def index
    if @user
      @events = @user.events.paginate(:include => [:app, :user], :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    else
      @events = Event.paginate(:all, :include => [:app, :user], :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    end
  end
  
  def synchronize
    sync_session = nil
    if @user
      sync_session = @user.sync_sessions.create!(:raw_xml => params[:doc])
      if @user == current_user
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
  
  private
  
  def load_user
    @user = User.find_by_login_and_active(params[:user_id], true)
  end
  
end
