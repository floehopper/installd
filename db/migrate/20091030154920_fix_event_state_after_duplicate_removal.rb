class FixEventStateAfterDuplicateRemoval < ActiveRecord::Migration
  
  def self.up
    User.all.each do |user|
      user.apps.each do |app|
        events = user.events.of_app(app)
        events.each do |event|
          if (event == events.first) && (event.state != 'Initial')
            puts "state=Initial: #{[event.id, event.user.login, event.sync.id, event.app.name, event.current, event.state, event.hashcode].inspect}"
            event.update_attributes(:state => 'Initial')
          end
          current = (event == events.last)
          unless (event.current == current)
            puts "current=#{current}: #{[event.id, event.user.login, event.sync.id, event.app.name, event.current, event.state, event.hashcode].inspect}"
            event.update_attributes(:current => current)
          end
        end
      end
    end
  end
  
  def self.down
    # irreversible
  end
  
end
