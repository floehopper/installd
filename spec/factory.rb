require 'factory_girl'

Factory.sequence :email do |sequence_number|
  "email-#{sequence_number}@example.com"
end

Factory.sequence :login do |sequence_number|
  "login-#{sequence_number}"
end

Factory.define :user do |user|
  user.email { Factory.next(:email) }
  user.active false
end

Factory.define :active_user, :class => User do |user|
  user.email { Factory.next(:email) }
  user.login { Factory.next(:login) }
  user.password 'password'
  user.active true
end

Factory.define :friendship do |friendship|
end