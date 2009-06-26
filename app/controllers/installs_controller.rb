require 'hpricot'

class InstallsController < ApplicationController
  
  def index
    @user = User.find_by_login(params[:user_id])
    if @user
      @installs = @user.installs.paginate(:include => :app, :page => params[:page], :per_page => 10)
    else
      @installs = Install.paginate(:include => :app, :page => params[:page], :per_page => 10)
    end
  end
  
  def synchronize
    user = User.find_by_login(params[:user_id])
    user.installs.clear
    doc = Hpricot::XML(params[:doc])
    (doc/'plist').each do |element|
      itemName = (element/'dict'/"key[text()='itemName']")[0].next_sibling.inner_text
      itemId = (element/'dict'/"key[text()='itemId']")[0].next_sibling.inner_text
      softwareIcon57x57URL = (element/'dict'/"key[text()='softwareIcon57x57URL']")[0].next_sibling.inner_text
      app = App.find_by_name(itemName) || App.create!(:name => itemName, :item_id => itemId, :icon_url => softwareIcon57x57URL)
      user.installs.create!(:app => app)
    end
    render :nothing => true, :status => :ok
  end
  
end
