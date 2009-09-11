class NetworksController < ApplicationController
  
  before_filter :load_user
  
  def show
    all_apps = App.find_by_sql(%{
      SELECT apps.*, COUNT(installs.id) AS number_of_installs, AVG(installs.rating) AS average_rating, MAX(installs.created_at) AS maximum_created_at FROM apps
        INNER JOIN installs ON (apps.id = installs.app_id)
        WHERE apps.id IN (SELECT apps.id FROM apps
          INNER JOIN installs ON (apps.id = installs.app_id)
          INNER JOIN users ON (installs.user_id = #{@user.id}))
        OR apps.id IN (SELECT apps.id FROM apps
          INNER JOIN installs ON (apps.id = installs.app_id)
          INNER JOIN users ON (installs.user_id = users.id)
          INNER JOIN connections ON (users.id = connections.connected_user_id)
          WHERE (connections.user_id = #{@user.id}))
        GROUP BY apps.id
        ORDER BY maximum_created_at DESC
    })
    @apps = all_apps.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
  end
  
  def in_common
    apps_in_common = App.find_by_sql(%{
      SELECT apps.*, COUNT(installs.id) AS number_of_installs, AVG(installs.rating) AS average_rating, MAX(installs.created_at) AS maximum_created_at FROM apps
        INNER JOIN installs ON (apps.id = installs.app_id)
        WHERE apps.id IN (SELECT apps.id FROM apps
          INNER JOIN installs ON (apps.id = installs.app_id)
          INNER JOIN users ON (installs.user_id = #{@user.id}))
        AND apps.id IN (SELECT apps.id FROM apps
          INNER JOIN installs ON (apps.id = installs.app_id)
          INNER JOIN users ON (installs.user_id = users.id)
          INNER JOIN connections ON (users.id = connections.connected_user_id)
          WHERE (connections.user_id = #{@user.id}))
        GROUP BY apps.id
        ORDER BY maximum_created_at DESC
    })
    @apps = apps_in_common.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  def not_in_common
    apps_not_in_common = App.find_by_sql(%{
      SELECT apps.*, COUNT(installs.id) AS number_of_installs, AVG(installs.rating) AS average_rating, MAX(installs.created_at) AS maximum_created_at FROM apps
        INNER JOIN installs ON (apps.id = installs.app_id)
        WHERE apps.id NOT IN (SELECT apps.id FROM apps
          INNER JOIN installs ON (apps.id = installs.app_id)
          INNER JOIN users ON (installs.user_id = #{@user.id}))
        AND apps.id IN (SELECT apps.id FROM apps
          INNER JOIN installs ON (apps.id = installs.app_id)
          INNER JOIN users ON (installs.user_id = users.id)
          INNER JOIN connections ON (users.id = connections.connected_user_id)
          WHERE (connections.user_id = #{@user.id}))
        GROUP BY apps.id
        ORDER BY maximum_created_at DESC
    })
    @apps = apps_not_in_common.paginate(:page => params[:page], :per_page => 15)
    @rss_feed_url = url_for(:format => 'rss')
    render :action => 'show'
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id])
  end
  
end