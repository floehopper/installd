require 'factory_girl'

Factory.sequence :login do |sequence_number|
  "login-#{sequence_number}"
end

Factory.define :user do |user|
  user.login { Factory.next(:login) }
  user.password 'password'
  user.password_confirmation 'password'
end

Factory.define :friendship do |friendship|
end