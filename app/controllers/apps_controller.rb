class AppsController < ApplicationController
  
  def show
    @app = App.find(params[:id])
    @installs = @app.installs.paginate(:order => 'created_at DESC', :page => params[:page], :per_page => 10)
  end
  
end