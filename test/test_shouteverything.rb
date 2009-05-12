require File.join(File.dirname(__FILE__), 'helpers')

class TestShoutEverything < Test::Unit::TestCase
  test "shouting at an IRC URI" do
    mock(ShoutEverything::IRC).new(:server => "example.org", :to => "foo") { nil }
    ShoutEverything.shout("irc://example.org/foo")
  end
end
