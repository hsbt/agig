require 'rubygems'
require 'net/irc'
require 'nokogiri'

require 'open-uri'
require 'ostruct'
require 'time'

class Agig::Session < Net::IRC::Server::Session
  EVENTS = {
    'DownloadEvent' => '6',
    'GistEvent'     => '10',
    'WatchEvent'    => '15',
    'FollowEvent'   => '15',
    'CreateEvent'   => '13',
    'ForkEvent'     => '3',
    'PushEvent'     => '14',
  }

  ACTIVITIES = %w(
    GistEvent
    ForkEvent
    FollowEvent
    WatchEvent
  )

  def server_name
    "github"
  end

  def server_version
    "0.0.0"
  end

  def main_channel
    @opts.main_channel || "#github"
  end

  def initialize(*args)
    super
    @last_retrieved = Time.now
  end

  def on_disconnected
    @retrieve_thread.kill rescue nil
  end

  def on_user(m)
    super

    @real, *@opts = @real.split(/\s+/)
    @opts = OpenStruct.new @opts.inject({}) {|r, i|
      key, value = i.split("=", 2)
      r.update key => case value
                      when nil                      then true
                      when /\A\d+\z/                then value.to_i
                      when /\A(?:\d+\.\d*|\.\d+)\z/ then value.to_f
                      else                               value
                      end
    }
    [main_channel, '#activity'].each {|c| post @nick, JOIN, c }

    @retrieve_thread = Thread.start do
      loop do
        begin
          @log.info 'retrieveing feed...'
          atom = open("https://github.com/#{@real}.private.atom?token=#{@pass}").read
          ns  = {'a' => 'http://www.w3.org/2005/Atom'}
          entries = Nokogiri::XML(atom).xpath('/a:feed/a:entry', ns).map do |entry|
            {
              :datetime => Time.parse(entry.xpath('string(a:published)', ns)),
              :id       => entry.xpath('string(a:id)', ns),
              :title    => entry.xpath('string(a:title)', ns),
              :author   => entry.xpath('string(a:author/a:name)', ns),
              :link     => entry.xpath('string(a:link/@href)', ns),
            }
          end

          entries.reverse_each do |entry|
            next if entry[:datetime] <= @last_retrieved
            type = entry[:id][%r|tag:github.com,2008:(.+?)/\d+|, 1]
            channel = ACTIVITIES.include? type ? '#activity' : main_channel
            post entry[:author], PRIVMSG, channel, "\003#{EVENTS[type] || '5'}#{entry[:title]}\017 \00314#{entry[:link]}\017"
          end

          @last_retrieved = entries.first[:datetime]
          @log.info 'sleep'
          sleep 30
        rescue Exception => e
          @log.error e.inspect
          e.backtrace.each do |l|
            @log.error "\t#{l}"
          end
          sleep 10
        end
      end
    end
  end
end
