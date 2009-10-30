class FixEventsInInitialState < ActiveRecord::Migration
  
  def self.up
    events = Event.find_all_by_state('Initial')
    events.each do |event|
      unless event.sync == event.user.syncs.first
        event.update_attributes(:state => 'Install')
      end
    end
  end
  
  def self.down
    # irreversible
  end
  
end
