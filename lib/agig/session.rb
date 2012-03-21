require 'net/irc'
require 'net/https'
require 'libxml'
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
    @cert_store = OpenSSL::X509::Store.new
    @cert_store.set_default_paths
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
    post @nick, JOIN, main_channel

    @retrieve_thread = Thread.start do
      loop do
        begin
          @log.info 'retrieveing feed...'
          uri = URI.parse("https://github.com/#{@real}.private.atom?token=#{@pass}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.cert_store = @cert_store
          req = Net::HTTP::Get.new(uri.request_uri)
          res = http.request(req)

          doc = LibXML::XML::Document.string(res.body, :base_uri => uri.to_s)
          ns  = %w|a:http://www.w3.org/2005/Atom|
            entries = []
          doc.find('/a:feed/a:entry', ns).each do |n|
            entries << {
              :datetime => Time.parse(n.find('string(a:published)', ns)),
              :id       => n.find('string(a:id)', ns),
              :title    => n.find('string(a:title)', ns),
              :author   => n.find('string(a:author/a:name)', ns),
              :link     => n.find('string(a:link/@href)', ns),
            }
          end

          entries.reverse_each do |entry|
            next if entry[:datetime] <= @last_retrieved
            type = entry[:id][%r|tag:github.com,2008:(.+?)/\d+|, 1]
            post entry[:author], PRIVMSG, main_channel,
            "\003#{EVENTS[type] || '5'}#{entry[:title]}\017 \00314#{entry[:link]}\017"
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
