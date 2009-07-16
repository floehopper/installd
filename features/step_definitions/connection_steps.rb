Given /^user with login "([^\"]*)" is connected to user with login "([^\"]*)"$/ do |user_login, connected_login|
  user = User.find_by_login(user_login)
  connected_user = User.find_by_login(connected_login)
  Factory(:connection, :user => user, :connected_user => connected_user)
end
