class DestroyDuplicateEvents < ActiveRecord::Migration
  
  def self.up
    Sync.all.each do |sync|
      User.all.each do |user|
        user.apps.each do |app|
          events = user.events.of_app(app)
          events_to_keep = []
          events.each do |event|
            previous_event = events_to_keep.last
            if event.can_follow?(previous_event)
              events_to_keep << event
            end
          end
          events_to_destroy = events - events_to_keep
          events_to_destroy.each do |event|
            puts "destroy: #{[event.id, event.user.login, event.sync.id, event.app.name, event.current, event.state, event.hashcode, event.purchased_at.to_s(:db)].inspect}"
            event.destroy
          end
        end
      end
    end
  end
  
  def self.down
    # irreversible
  end
  
end
