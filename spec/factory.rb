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
  app.artist_name 'artist-name'
  app.artist_id 'artist-id'
  app.genre 'genre'
  app.genre_id 'genre-id'
end

Factory.define :install_from_xml, :class => Install do |install|
  install.raw_xml '<xml></xml>'
  install.price 999
  install.display_price '£9.99'
  install.released_at Time.parse('2009-01-01 00:00:00')
  install.purchased_at Time.parse('2009-01-01 00:00:00')
  install.store_code 'store-code'
  install.software_version_bundle_id 'bundle-id'
  install.software_version_external_identifier 'external-identifier'
end

Factory.define :install, :parent => :install_from_xml do |install|
  install.association :sync
end

Factory.define :sync do |sync|
  sync.association :user
end

