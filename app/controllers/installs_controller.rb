class InstallsController < ApplicationController
  
  ssl_required :synchronize
  
  def index
    user_id = params[:user_id]
    if user_id
      @user = User.find_by_login(user_id)
      @installs = @user.installs.paginate(:include => [:app, :user], :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    else
      @installs = Install.paginate(:all, :include => [:app, :user], :order => 'created_at DESC', :page => params[:page], :per_page => 15)
    end
  end
  
  def update
    @install = Install.find(params[:id])
    if @install.can_be_updated_by?(current_user)
      rating = params[:install] && params[:install][:rating]
      @install.update_attributes(:rating => rating, :rated_at => Time.now)
    end
    respond_to do |format|
     format.js { render :nothing => true }
     format.html { redirect_to :back }
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
