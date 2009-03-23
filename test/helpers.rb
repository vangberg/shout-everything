require 'rubygems'
require 'rr'
require 'test/unit'
require 'contest'
require 'timeout'
require 'lib/shouteverything'

class MockSocket
  def self.pipe
    socket1, socket2 = new, new
    socket1.in, socket2.out = IO.pipe
    socket2.in, socket1.out = IO.pipe
    [socket1, socket2]
  end
 
  attr_accessor :in, :out
  def gets
    Timeout.timeout(1) {@in.gets}
  end

  def puts(m) @out.puts(m) end

  def eof?() true end

  def empty?
    begin
      @in.read_nonblock(1)
      false
    rescue Errno::EAGAIN
      true
    end
  end
end


class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
