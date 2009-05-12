$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "uri"

module ShoutEverything
  autoload :IRC, "shouteverything/irc"

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
