class DestroyOutOfSequenceEvents < ActiveRecord::Migration
  
  def self.up
    User.all.each do |user|
      user.apps.uniq.each do |app|
        events = user.events.of_app(app)
        events_to_keep = []
        events.each do |event|
          previous_event = events_to_keep.last
          if event.state_allowed_based_on?(previous_event)
            events_to_keep << event
          end
        end
        events_to_destroy = events - events_to_keep
        unless events_to_destroy.empty?
          puts "======================="
          events_to_destroy.each do |event|
            puts "destroy: #{[event.id, event.user.login, event.sync_session.id, event.app.name, event.current, event.state, event.hashcode, event.purchased_at.to_s(:db)].inspect}"
            event.destroy
          end
          events_to_keep.each do |event|
            current = (event == events_to_keep.last)
            unless event.current? == current
              puts "update current (#{current}): #{[event.id, event.user.login, event.sync_session.id, event.app.name, event.current, event.state, event.hashcode, event.purchased_at.to_s(:db)].inspect}"
              event.update_attributes(:current => current)
            end
          end
        end
      end
    end
  end
  
  def self.down
    # irreversible
  end
  
end
