require "optparse"

module Agig::OptParser
  def self.parse!(argv)
    opts = {
      :port  => 16705,
      :host  => "localhost",
      :interval => 30,
      :log   => nil,
      :debug => false,
      :foreground => false,
    }

    OptionParser.new do |parser|
      parser.instance_eval do
        self.banner  = "Usage: #{$0} [opts]"
        separator ""

        separator "Options:"
        on("-p", "--port [PORT=#{opts[:port]}]", "port number to listen") do |port|
          opts[:port] = port
        end

        on("-h", "--host [HOST=#{opts[:host]}]", "host name or IP address to listen") do |host|
          opts[:host] = host
        end

        on("-i", "--interval [INTERVAL=#{opts[:interval]}]", "set a retrieving interval") do |interval|
          opts[:interval] = interval
        end

        on("-l", "--log LOG", "log file") do |log|
          opts[:log] = log
        end

        on("-d", "--debug", "Enable debug mode") do |debug|
          opts[:log]   = $stdout
          opts[:debug] = true
        end

        on("-f", "--foreground", "run foreground") do |foreground|
          opts[:log]        = $stdout
          opts[:foreground] = true
        end

        parse!(argv)
      end
    end

    opts
  end
end
