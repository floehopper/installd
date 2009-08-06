class ActivationsController < ApplicationController
  
  before_filter :load_user
  before_filter :redirect_to_new_user_path_if_user_not_found
  before_filter :redirect_to_new_user_session_path_if_user_already_active
  
  def create
    if @user.update_attributes(params[:user].merge(:active => true))
      UserMailer.deliver_activation(@user)
      flash[:notice] = 'Activation successful.'
      redirect_to downloads_path
    else
      flash[:notice] = 'Some fields were invalid.'
      render :action => 'new'
    end
  end
  
  private
  
    def load_user
      @user = User.find_using_perishable_token(params[:code], 0)
    end
    
    def redirect_to_new_user_path_if_user_not_found
      unless @user
        flash[:notice] = 'Invalid activation code.'
        redirect_to new_user_path
      end
    end
    
    def redirect_to_new_user_session_path_if_user_already_active
      if @user.active?
        flash[:notice] = 'Account already active.'
        redirect_to new_user_session_path
      end
    end
  
end