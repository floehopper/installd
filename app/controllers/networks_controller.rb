class NetworksController < ApplicationController
  
  before_filter :load_user
  
  def show
    all_apps = App.all(
      :select => %{
        apps.*,
        COUNT(installs.id) AS number_of_installs,
        AVG(installs.rating) AS average_rating,
        MAX(installs.created_at) AS maximum_created_at
      },
      :joins => %{
        INNER JOIN installs
          ON (apps.id = installs.app_id)
      },
      :conditions => %{
        apps.id IN (#{@user.app_ids_sql})
        OR
        apps.id IN (#{@user.connected_app_ids_sql})
      },
      :group => 'apps.id',
      :order => 'maximum_created_at DESC'
    )
    @apps = all_apps.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
  end
  
  def in_common
    apps_in_common = App.all(
      :select => %{
        apps.*,
        COUNT(installs.id) AS number_of_installs,
        AVG(installs.rating) AS average_rating,
        MAX(installs.created_at) AS maximum_created_at
      },
      :joins => %{
        INNER JOIN installs
          ON (apps.id = installs.app_id)
      },
      :conditions => %{
        apps.id IN (#{@user.app_ids_sql})
        AND
        apps.id IN (#{@user.connected_app_ids_sql})
      },
      :group => 'apps.id',
      :order => 'maximum_created_at DESC'
    )
    @apps = apps_in_common.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  def not_in_common
    apps_not_in_common = App.all(
      :select => %{
        apps.*,
        COUNT(installs.id) AS number_of_installs,
        AVG(installs.rating) AS average_rating,
        MAX(installs.created_at) AS maximum_created_at
      },
      :joins => %{
        INNER JOIN installs
          ON (apps.id = installs.app_id)
      },
      :conditions => %{
        apps.id NOT IN (#{@user.app_ids_sql})
        AND
        apps.id IN (#{@user.connected_app_ids_sql})
      },
      :group => 'apps.id',
      :order => 'maximum_created_at DESC'
    )
    @apps = apps_not_in_common.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id])
  end
  
end