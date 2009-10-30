class DestroyDuplicateEvents < ActiveRecord::Migration
  
  def self.up
    Sync.all.each do |sync|
      apps_vs_events = sync.events.group_by(&:app)
      apps_vs_events.each do |(app, events)|
        if events.size > 1
          latest_event = events.sort_by(&:purchased_at).last
          events.each do |event|
            unless event == latest_event
              puts "destroy: #{[event.id, event.user.login, sync.id, app.name, event.current, event.state, event.purchased_at.to_s(:db)].inspect}"
              event.destroy
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
