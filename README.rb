ShoutEverything::Twitter.shout(:user => 'foo', :password => 'login') do |t|
  t.say "baz"
end
 
ShoutEverything::IRC.shout(:nick => 'foo', :server => 'irc.freenode.net', :to => '#bar') do |c|
  c.say "baz"
end
 
channels = {
  :twitter => {:user => 'foo', :password => 'secret'},
  :irc => {:nick => 'foo', :server => 'irc.freenode.net', :to => 'private_nick'}
}
ShoutEverything.shout(channels) do |s|
  s.say "hello world to all channels"
end
 
ShoutEverything::Mail
ShoutEverything::Jabber
ShoutEverything::Yammer
ShoutEverything::Campfire
ShoutEverything::Basecamp
ShoutEverything::Growl
