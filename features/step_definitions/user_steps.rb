Given /^a user exists with email "([^\"]*)"$/ do |email|
  Factory(:user, :email => email)
end

Given /^an active user exists with login "([^\"]*)"$/ do |login|
  Factory(:active_user, :login => login)
end

Given /^an active user exists with login "([^\"]*)" and password "([^\"]*)"$/ do |login, password|
  Factory(:active_user, :login => login, :password => password)
end

Given /^no user exists with email "([^\"]*)"$/ do |email|
  User.find_by_email(email).should be_nil
end

Given /^no user exists with login "([^\"]*)"$/ do |login|
  User.find_by_login(login).should be_nil
end

Given /^user with login "([^\"]*)" has the following applications installed:$/ do |login, apps|
  user = User.find_by_login(login)
  apps.hashes.each do |attributes|
    attributes.symbolize_keys!
    app = App.find_by_name(attributes[:name]) || App.create!(attributes)
    user.installs.create!(:app => app)
  end
end
