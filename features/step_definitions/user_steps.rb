Given /^a user exists with login "([^\"]*)"$/ do |login|
  Factory(:user, :login => login)
end

Given /^a user exists with login "([^\"]*)" and password "([^\"]*)"$/ do |login, password|
  Factory(:user, :login => login, :password => password, :password_confirmation => password)
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
