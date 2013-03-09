require 'ostruct'
require 'time'
require 'net/irc'
require 'octokit'

class Agig::Session < Net::IRC::Server::Session
  def server_name
    "github"
  end

  def server_version
    "0.0.0"
  end

  def channel
    "#github"
  end

  def initialize(*args)
    super
    @last_retrieved = Time.now.utc
  end

  def client
    @client ||= Octokit::Client.new(login: @nick, password: @pass)
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
    post @nick, JOIN, channel

    @retrieve_thread = Thread.start do
      loop do
        begin
          @log.info 'retrieveing feed...'

          entries = client.notifications
          entries.sort_by(&:updated_at).reverse_each do |entry|
            updated_at = Time.parse(entry[:updated_at]).utc
            next if updated_at <= @last_retrieved

            subject = entry['subject']
            post entry['repository']['owner']['login'], PRIVMSG, "#github", "\0035#{subject['title']}\017 \00314#{subject['latest_comment_url']}\017"
          end

          events = client.received_events('hsbt')
          events.sort_by(&:created_at).reverse_each do |event|
            created_at = Time.parse(event.created_at).utc
            next if created_at <= @last_retrieved || event.type != "WatchEvent"

            post event.actor.login, PRIVMSG, "#watch", "\0035#{event.payload.action}\017 \00314http://github.com/#{event.repo.name}\017"
          end

          @last_retrieved = Time.now.utc

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
