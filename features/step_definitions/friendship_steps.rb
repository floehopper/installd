Given /^user with login "([^\"]*)" is friends with user with login "([^\"]*)"$/ do |user_login, friend_login|
  user = User.find_by_login(user_login)
  friend = User.find_by_login(friend_login)
  Factory(:friendship, :user => user, :friend => friend)
end
