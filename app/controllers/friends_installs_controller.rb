class FriendsInstallsController < ApplicationController
  
  def index
    filter = params[:filter]
    @user = User.find_by_login(params[:user_id], :include => { :installs => :app })
    apps_vs_friends_installs = @user.friends_installs(:include => :app).group_by(&:app).sort_by { |app, installs| -installs.length }
    case filter
      when 'common'
        apps_vs_friends_installs.reject! { |app, installs| !@user.apps.include?(app) }
      when 'uncommon'
        apps_vs_friends_installs.reject! { |app, installs| @user.apps.include?(app) }
    end
    @friends_installs = apps_vs_friends_installs.paginate(:page => params[:page], :per_page => 10)
  end
  
end