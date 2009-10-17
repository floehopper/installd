class AddSyncs < ActiveRecord::Migration
  
  def self.up
    create_table :syncs, :force => true do |t|
      t.integer :user_id
      t.string :status
      t.timestamps
    end
    add_index :syncs, :user_id
    
    add_column :installs, :sync_id, :integer
    add_index :installs, :sync_id
    
    Sync.record_timestamps = false
    User.all.each do |user|
      
      sync_dates = user.installs.find(
        :all,
        :select => 'DATE(created_at) AS created_on',
        :group => 'DATE(created_at)'
      ).map(&:created_on)
      
      sync_dates.each do |sync_date|
        sync = user.syncs.create!(
          :status => 'ok',
          :created_at => sync_date,
          :updated_at => sync_date
        )
        installs = user.installs.find(
          :all,
          :conditions => ['DATE(created_at) = ?', sync_date]
        )
        sync.installs << installs
      end
      
    end
    
    Sync.record_timestamps = true
  end
  
  def self.down
    remove_index :installs, :sync_id
    remove_column :installs, :sync_id
    
    remove_index :syncs, :user_id
    drop_table :syncs
  end
  
end
