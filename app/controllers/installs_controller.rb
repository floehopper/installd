class InstallsController < ApplicationController
  
  before_filter :require_user, :only => :synchronize
  
  def index
    @user = User.find_by_login(params[:user_id])
    if @user
      @installs = @user.installs.paginate(:include => :app, :page => params[:page], :per_page => 10)
    else
      @installs = Install.paginate(:include => :app, :page => params[:page], :per_page => 10)
    end
  end
  
  def recent
    @installs = Install.paginate(:order => 'created_at DESC', :include => :app, :page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
  end
  
  def popular
    @installs = Install.paginate(:select => '*, COUNT(*) AS number_of_installs', :group => 'app_id', :order => 'number_of_installs DESC', :include => :app, :page => params[:page], :per_page => 15)
  end
  
  def update
    @user = User.find_by_login(params[:user_id])
    @install = Install.find(params[:id])
    attributes = params[:install] || {}
    attributes[:rating] ||= nil
    @install.update_attributes(attributes)
    render :nothing => true
  end
  
  def synchronize
    user = User.find_by_login(params[:user_id])
    installs = user.installs.dup
    parser = IphoneAppPlistParser.new(params[:doc])
    parser.each_app do |attributes|
      app = App.find_by_name(attributes[:name]) || App.create!(
        attributes.slice(
          :name,
          :item_id,
          :icon_url,
          :artist_name,
          :artist_id,
          :genre,
          :genre_id
        )
      )
      install = user.installs.find_by_app_id(app.id)
      if install
        installs.delete(install)
      else
        user.installs.create!(
          attributes.slice(
            :price,
            :display_price,
            :purchased_at,
            :released_at,
            :store_code,
            :software_version_bundle_id,
            :software_version_external_identifier,
            :raw_xml
          ).merge(:app => app)
        )
      end
    end
    installs.each { |install| install.destroy }
    render :nothing => true, :status => :ok
  end
  
end
