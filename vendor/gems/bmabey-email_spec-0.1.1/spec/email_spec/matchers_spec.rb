
require File.dirname(__FILE__) + '/../spec_helper'



describe EmailSpec::Matchers do


    class MatcherMatch

      def initialize(object_to_test_match)
        @object_to_test_match = object_to_test_match
      end

      def description
        "match when provided #{@object_to_test_match.inspect}"
      end

      def matches?(matcher)
        @matcher = matcher
        matcher.matches?(@object_to_test_match)
      end

      def failure_message
        "expected #{@matcher.inspect} to match when provided #{@object_to_test_match.inspect}, but it did not"
      end

      def negative_failure_message
        "expected #{@matcher.inspect} not to match when provided #{@object_to_test_match.inspect}, but it did"
      end
    end

    def match(object_to_test_match)
      if object_to_test_match.is_a?(Regexp)
        super # delegate to rspec's built in 'match' matcher
      else
        MatcherMatch.new(object_to_test_match)
      end
    end

  include EmailSpec::Matchers

  def mock_email(stubs)
    mock("email", stubs)
  end

  describe "#deliver_to" do

    it "should match when the email is set to deliver to the specidied address" do
      email = mock_email(:to => "jimmy_bean@yahoo.com")

      deliver_to("jimmy_bean@yahoo.com").should match(email)
    end

    it "should match when a list of emails is exact same as all of the email's recipients" do
      email = mock_email(:to => ["james@yahoo.com", "karen@yahoo.com"])

      deliver_to("karen@yahoo.com", "james@yahoo.com").should match(email)
      deliver_to("karen@yahoo.com").should_not match(email)
    end

    it "should match when an array of emails is exact same as all of the email's recipients" do
      addresses = ["james@yahoo.com", "karen@yahoo.com"]
      email = mock_email(:to => addresses)
      deliver_to(addresses).should match(email)
    end

    it "should use the passed in objects :email method if not a string" do
      email = mock_email(:to => "jimmy_bean@yahoo.com")
      user = mock("user", :email => "jimmy_bean@yahoo.com")

      deliver_to(user).should match(email)
    end

  end

  describe "#have_subject" do

    describe "when regexps are used" do

      it "should match when the subject mathches regexp" do
        email = mock_email(:subject => ' -- The Subject --')

        have_subject(/The Subject/).should match(email)
        have_subject(/The Subject/).should match(email)
        have_subject(/foo/).should_not match(email)
      end

      it "should have a helpful description" do
        matcher = have_subject(/foo/)
        matcher.matches?(mock_email(:subject => "bar"))

        matcher.description.should == "have subject matching /foo/"
      end

      it "should offer helpful failing messages" do
        matcher = have_subject(/foo/)
        matcher.matches?(mock_email(:subject => "bar"))

        matcher.failure_message.should == 'expected the subject to match /foo/, but did not.  Actual subject was: "bar"'
      end

      it "should offer helpful negative failing messages" do
        matcher = have_subject(/b/)
        matcher.matches?(mock_email(:subject => "bar"))

        matcher.negative_failure_message.should == 'expected the subject not to match /b/ but "bar" does match it.'
      end

    end

    describe "when strings are used" do

      it "should match when the subject equals the passed in string exactly" do
        email = mock_email(:subject => 'foo')

        have_subject("foo").should match(email)
        have_subject(" - foo -").should_not match(email)
      end

      it "should have a helpful description" do
        matcher = have_subject("foo")
        matcher.matches?(mock_email(:subject => "bar"))

        matcher.description.should == 'have subject of "foo"'
      end

      it "should offer helpful failing messages" do
        matcher = have_subject("foo")
        matcher.matches?(mock_email(:subject => "bar"))

        matcher.failure_message.should == 'expected the subject to be "foo" but was "bar"'
      end


      it "should offer helpful negative failing messages" do
        matcher = have_subject("bar")
        matcher.matches?(mock_email(:subject => "bar"))

        matcher.negative_failure_message.should == 'expected the subject not to be "bar" but was'
      end

    end


  end

  describe "#include_email_with_subject" do
    it "should have specs!"
  end

  describe "#have_body_text" do
    it "should have specs!"
  end
  
  describe "#have_header" do
    it "should have specs!"
  end
end
