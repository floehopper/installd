namespace :user do
  
  desc 'Send invitations to inactive users that have been waiting the longest (limited by MAXIMUM_NUMBER_OF_INVITATIONS)'
  task :send_invitations => :environment do
    maximum_number_of_invitations = ENV['MAX_INVITATIONS']
    User.send_invitations(maximum_number_of_invitations)
  end
  
end