require File.join(File.dirname(__FILE__), 'helpers')

class ShoutEverything::IRC
  include Test::Unit::Assertions
end

class TestIRC < Test::Unit::TestCase
  def setup
    @socket, @server = MockSocket.pipe
    stub(TCPSocket).open(anything, anything) {@socket}
  end

  def create_shoutbot(&block)
    ShoutEverything::IRC.new("irc.freenode.net", 6667, "john", &block || lambda {})
  end

  def create_shoutbot_and_register(&block)
    create_shoutbot &block
    2.times { @server.gets } # NICK + USER
  end

  test "raises error if no block given" do
    assert_raises ArgumentError do
      ShoutEverything::IRC.new("irc.freenode.net", 6667, "john")
    end
  end

  test "registers to the irc server" do
    create_shoutbot
    assert_equal "NICK john\n", @server.gets
    assert_equal "USER john john john :john\n", @server.gets
  end

  test "sends password if specified" do
    # hey, retarded test!
    ShoutEverything::IRC.new("irc.freenode.net", 6667, "john", "malbec") {@socket}
    assert_equal "PASSWORD malbec\n", @server.gets
  end

  test "falls back to port 6667 if not specified" do
    # talk about retarded test
    mock(TCPSocket).open("irc.freenode.net", 6667) {@socket}
    ShoutEverything::IRC.new("irc.freenode.net", nil, "john") {}
  end

  test "quits after doing its job" do
    create_shoutbot_and_register {}
    assert_equal "QUIT\n", @server.gets
  end

  test "raises error if no block is given to join" do
    create_shoutbot do |bot|
      assert_raises(ArgumentError) {bot.join "integrity"}
    end
  end

  test "joins channel" do
    create_shoutbot_and_register do |bot|
      bot.join("integrity") {}
    end
    assert_equal "JOIN #integrity\n", @server.gets
  end

  test "doesn't do anything until receiving RPL_MYINFO / 004" do
    # pending
  end

  test "joins channel and says something" do
    create_shoutbot_and_register do |bot|
      bot.join "integrity" do |c|
        c.say "foo bar!"
      end
    end
    @server.gets # JOIN
    assert_equal "PRIVMSG #integrity :foo bar!\n", @server.gets
  end

  test "sends private message to user" do
    create_shoutbot_and_register do |bot|
      bot.channel = "sr"
      bot.say "Look Ma, new tests!"
    end
    assert_equal "PRIVMSG sr :Look Ma, new tests!\n", @server.gets
  end
end

class TestShoutIRC < Test::Unit::TestCase
  def setup
    @socket, @server = MockSocket.pipe
    stub(TCPSocket).open(anything, anything) {@socket}
  end

  def create_shouter(&block)
    shouter = ShoutEverything::IRC.new("irc.freenode.net", 6667, "shouter") {}
    mock(ShoutEverything::IRC).new(anything, anything, anything, anything).yields(shouter) {shouter}
    shouter
  end

  test "raises error unless block is given" do
    assert_raises ArgumentError do
      ShoutEverything::IRC.shout(:nick => 'shouter', :server => 'irc.freenode.net', :port => 6667, :to => 'foo')
    end
  end

  test "creates a new instance of shoutbot" do
    mock(ShoutEverything::IRC).new("irc.freenode.net", 6667, "shouter", nil)
    ShoutEverything::IRC.shout(:nick => 'shouter', :server => 'irc.freenode.net', :port => 6667, :to => 'foo') {}
  end

  test "creates a new instance of shoutbot with password" do
    mock(ShoutEverything::IRC).new("irc.freenode.net", 6667, "shouter", "badass")
    ShoutEverything::IRC.shout(:nick => 'shouter', :password => 'badass', :server => 'irc.freenode.net', :port => 6667, :to => 'foo') {}
  end

  test "joins channel" do
    shouter = create_shouter
    mock(shouter).join("integrity")
    ShoutEverything::IRC.shout(:nick => 'shouter', :server => 'irc.freenode.net', :port => 6667, :to => '#integrity') {}
  end

  test "says stuff in channel" do
    shouter = create_shouter
    mock(shouter).say("foo bar!")
    ShoutEverything::IRC.shout(:nick => 'shouter', :server => 'irc.freenode.net', :port => 6667, :to => '#integrity') do |bot|
      bot.say "foo bar!"
    end
    assert_equal "#integrity", shouter.channel
  end

  test "sends private message to nick" do
    shouter = create_shouter
    mock(shouter).say("foo bar!")
    ShoutEverything::IRC.shout(:nick => 'shouter', :server => 'irc.freenode.net', :port => 6667, :to => 'harry') do |bot|
      bot.say "foo bar!"
    end
    assert_equal "harry", shouter.channel
  end
end
