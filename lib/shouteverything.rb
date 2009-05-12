$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "uri"
require 'shouteverything/irc'

module ShoutEverything
  def self.shout(uri, &block)
    uri = URI(uri)

    case uri.scheme
    when "irc"
      IRC.new(:server => uri.host, :to => uri.path[1..-1])
    else
      nil
    end
  end
end
