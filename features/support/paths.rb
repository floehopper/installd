module NavigationHelpers
  def path_to(page_name)
    case page_name
    
    when /the home page/
      root_path
    
    when /the user page for "([^\"]*)"/
      user_path($1)
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
    end
  end
end

World do |world|
  world.extend NavigationHelpers
  world
end
