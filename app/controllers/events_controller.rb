class EventsController < ApplicationController
  
  ssl_required :synchronize
  before_filter :load_user
  
  before_filter :require_user, :only => [:manual_uninstall]
  before_filter :require_authorized_user, :only => [:manual_uninstall]
  before_filter :load_app, :only => [:manual_uninstall]
  before_filter :require_app, :only => [:manual_uninstall]
  
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
  
  def manual_uninstall
    sync_session = @user.sync_sessions.create!(:status => 'manual')
    @user.create_manual_uninstall!(@app, sync_session)
    respond_to do |format|
     format.js { render :nothing => true }
     format.html { redirect_to :back }
    end
  end
  
  private
  
  def load_user
    @user = User.find_by_login_and_active(params[:user_id], true)
  end
  
  def require_authorized_user
    unless @user == current_user
      flash[:notice] = 'You are not authorized to create events for this user.'
      redirect_to @user
    end
  end
  
  def load_app
    @app = App.find(params[:app_id])
  end
  
  def require_app
    unless @app
      flash[:notice] = 'Cannot find the app for which you want to create event.'
      redirect_to @user
    end
  end
  
end
