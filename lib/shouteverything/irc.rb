require "socket"

module ShoutEverything
  class IRC
    def self.shout(options, &block)
      raise ArgumentError unless block_given?

      irc = new(options[:server], options[:port], options[:nick], options[:password]) do |irc|
        to = options[:to]
        if to =~ /^#/
          irc.join(to[1..-1], &block)
        else
          irc.channel = to
          yield irc
        end
      end
    end

    attr_accessor :channel

    def initialize(server, port, nick, password=nil)
      raise ArgumentError unless block_given?

      @socket = TCPSocket.open(server, port || 6667)
      @socket.puts "PASSWORD #{password}" if password
      @socket.puts "NICK #{nick}"
      @socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
      sleep 1 unless defined? Test::Unit
      yield self
      @socket.puts "QUIT"
      @socket.gets until @socket.eof?
    end

    def join(channel)
      raise ArgumentError unless block_given?

      @channel = "##{channel}"
      @socket.puts "JOIN #{@channel}"
      yield self
      @socket.puts "PART #{@channel}"
    end

    def say(message)
      return unless @channel
      @socket.puts "PRIVMSG #{@channel} :#{message}"
    end
  end
end
