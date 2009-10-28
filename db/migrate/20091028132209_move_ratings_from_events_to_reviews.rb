class MoveRatingsFromEventsToReviews < ActiveRecord::Migration
  
  def self.up
    add_column :reviews, :rating, :integer
    
    events = Event.find(:all, :conditions => ['rating IS NOT NULL'], :order => 'created_at')
    grouped_events = events.group_by { |event| [event.user_id, event.app_id].join(',') }
    events_with_latest_rating = grouped_events.values.map(&:last)
    
    Review.record_timestamps = false
    events_with_latest_rating.each do |event|
      Review.create!(
        :user => event.user,
        :app => event.app,
        :rating => event.rating,
        :created_at => event.rated_at
      )
    end
    Review.record_timestamps = true
    
    remove_column :events, :rating
    remove_column :events, :rated_at
  end
  
  def self.down
    add_column :events, :rated_at, :datetime
    add_column :events, :rating, :integer
    
    Review.all.each do |review|
      latest_event = review.user.events.of_app(review.app).last
      if latest_event
        latest_event.update_attributes!(
          :rating => review.rating,
          :rated_at => review.created_at
        )
      end
    end
    
    Review.delete_all
    remove_column :reviews, :rating
  end
  
end
