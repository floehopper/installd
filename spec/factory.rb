require 'factory_girl'

Factory.sequence :email do |sequence_number|
  "email-#{sequence_number}@example.com"
end

Factory.sequence :login do |sequence_number|
  "login-#{sequence_number}"
end

Factory.sequence :app_name do |sequence_number|
  "app-#{sequence_number}"
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

Factory.define :connection do |connection|
end

Factory.define :app do |app|
  app.name { Factory.next(:app_name) }
  app.item_id '1234'
  app.icon_url "http://installd.com/images/logo.png"
end
