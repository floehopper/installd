class CreateInvitations < ActiveRecord::Migration
  
  def self.up
    create_table :invitations, :force => true do |t|
      t.integer :user_id
      t.timestamps
    end
    add_index :invitations, :user_id
    User.all.each do |user|
      if invited_at = user.invited_at
        user.invitations.create!(:created_at => invited_at, :updated_at => invited_at)
      end
    end
    remove_column :users, :invited_at
  end
  
  def self.down
    add_column :users, :invited_at, :datetime
    User.all.each do |user|
      if invitation = user.invitations.last
        user.update_attribute(:invited_at, invitation.created_at)
      end
    end
    remove_index :invitations, :user_id
    drop_table :invitations
  end
  
end
