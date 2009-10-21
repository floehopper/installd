set :output, File.expand_path('schedule.log', File.join(Rails.root, 'log'))

every 1.day, :at => '4:30 am' do
  rake "db:backup"
end
