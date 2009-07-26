class AddInvitedAtToUsers < ActiveRecord::Migration
  
  def self.up
    add_column :users, :invited_at, :datetime
    update %{ UPDATE users SET invited_at = created_at WHERE invited_at IS NULL }
  end
  
  def self.down
    remove_column :users, :invited_at
  end
  
end
