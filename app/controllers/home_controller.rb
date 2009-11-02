class HomeController < ApplicationController
  
  def recent
    redirect_to recent_apps_path(params.slice(:format)), :status => :moved_permanently
  end
  
  def popular
    redirect_to popular_apps_path(params.slice(:format)), :status => :moved_permanently
  end
  
end