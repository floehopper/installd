set :output, File.expand_path('schedule.log', File.join(Rails.root, 'log'))

# every 1.day, :at => '4:30 am' do
every 5.minutes do
  rake "db:backup"
end
