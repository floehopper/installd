class SetCurrentToTrueOrFalseOnEvents < ActiveRecord::Migration
  
  def self.up
    update %{
      UPDATE events SET current = 0 WHERE current IS NULL
    }
  end
  
  def self.down
    # irreversible
  end
  
end
