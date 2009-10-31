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

Factory.define :event_from_xml, :class => Event do |event|
  event.raw_xml '<xml></xml>'
  event.price 999
  event.display_price '£9.99'
  event.released_at Time.parse('2009-01-01 00:00:00')
  event.purchased_at Time.parse('2009-01-01 00:00:00')
  event.store_code 'store-code'
  event.software_version_bundle_id 'bundle-id'
  event.software_version_external_identifier 'external-identifier'
end

Factory.define :event, :parent => :event_from_xml do |event|
  event.association :sync
  event.current true
  event.state 'Initial'
end

Factory.define :sync do |sync|
  sync.association :user
end

Factory.define :successful_sync, :class => Sync, :parent => :sync do |sync|
  sync.status 'success'
end
