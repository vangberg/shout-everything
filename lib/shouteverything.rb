$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'shouteverything/irc'

module ShoutEverything
  extend self

  def shout(options, &block)
    # ...
  end
end
