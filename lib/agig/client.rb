require 'net/irc'
require 'logger'

module Agig::Client
  def self.run
    opts = Agig::OptParser.parse!(ARGV)

    if opts[:log]
      opts[:logger] = Logger.new(opts[:log], "daily")
      opts[:logger].level = opts[:debug] ? Logger::DEBUG : Logger::INFO
    end

    Net::IRC::Server.new(opts[:host], opts[:port], Agig::Session, opts).start
  end
end
