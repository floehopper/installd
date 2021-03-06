Feature: Spec::ExampleGroup with should methods

  As an RSpec adopter accustomed to classes and methods
  I want to use should_* methods in an ExampleGroup
  So that I use RSpec with classes and methods that look more like RSpec examples

  Scenario: Run with ruby
    Given the file ../../resources/spec/example_group_with_should_methods.rb
    When I run it with the ruby interpreter
    Then the exit code should be 256
    And the stdout should match "2 examples, 1 failure"

  Scenario: Run with spec
  Given the file ../../resources/spec/example_group_with_should_methods.rb
    When I run it with the spec command
    Then the exit code should be 256
    And the stdout should match "2 examples, 1 failure"
