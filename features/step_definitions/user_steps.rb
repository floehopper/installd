Given /^a user exists with login "([^\"]*)"$/ do |login|
  Factory(:user, :login => login)
end

Given /^user with login "([^\"]*)" has the following applications installed:$/ do |login, apps|
  user = User.find_by_login(login)
  apps.hashes.each do |attributes|
    app = App.find_or_create_by_name(attributes['name'])
    user.installs.create!(:app => app)
  end
end

Then /^I should see an application with name "([^\"]*)"$/ do |name|
  response.should have_tag('.apps > .app', :text => name)
end
