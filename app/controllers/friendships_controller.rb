class FriendshipsController < ApplicationController
  
  def new
    @friend = User.find_by_login(params[:user_id])
    @friendship = Friendship.new(:user => current_user, :friend => @friend)
  end
  
  def create
    @friend = User.find_by_login(params[:user_id])
    @friendship = Friendship.new(:user => current_user, :friend => @friend)
    if @friendship.save
      flash[:notice] = "#{@friend.login} has been added as a friend."
      redirect_to @friend
    else
      render :action => 'new'
    end
  end
  
end