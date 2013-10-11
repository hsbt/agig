require 'ostruct'
require 'time'
require 'net/irc'
require 'octokit'

class Agig::Session < Net::IRC::Server::Session
  def server_name
    "github"
  end

  def server_version
    Agig::VERSION
  end

  def channels
    ['#notification', '#watch']
  end

  def initialize(*args)
    super
    @notification_last_retrieved = @watch_last_retrieved = Time.now.utc - 3600
  end

  def client
    @client ||= if @opts.oauth_token
                  Octokit::Client.new(oauth_token: @pass)
                else
                  Octokit::Client.new(login: @nick, password: @pass)
                end
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
    channels.each{|channel| post @nick, JOIN, channel }

    @retrieve_thread = Thread.start do
      loop do
        begin
          @log.info 'retrieveing feed...'

          entries = client.notifications(all: true)
          entries.sort_by(&:updated_at).reverse_each do |entry|
            updated_at = Time.parse(entry.updated_at).utc
            next if updated_at <= @notification_last_retrieved

            reachable_url = reachable_url_for(entry.subject.latest_comment_url)

            post entry.repository.owner.login, PRIVMSG, "#notification", "\0035#{entry.subject.title}\017 \00314#{reachable_url}\017"
            @notification_last_retrieved = updated_at
          end

          events = client.received_events(@nick)
          events.sort_by(&:created_at).reverse_each do |event|
            next if event.type != "WatchEvent"

            created_at = Time.parse(event.created_at).utc
            next if created_at <= @watch_last_retrieved

            post event.actor.login, PRIVMSG, "#watch", "\0035#{event.payload.action}\017 \00314http://github.com/#{event.repo.name}\017"
            @watch_last_retrieved = created_at
          end

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

  private

  def reachable_url_for(latest_comment_url)
    repos_owner = latest_comment_url.match(/repos\/(.+?\/.+?)\//)[1]
    if issue_match = latest_comment_url.match(/(?:issues|pulls)\/(\d+?)$/)
      issue_id = issue_match[1]
      latest_comment = client.issue_comments(repos_owner, issue_id).last
      latest_comment ?
        latest_comment['html_url'] :
        latest_comment_url.sub(/api\./, '').sub(/repos\//, '').sub(/pulls\//, 'pull/')
    elsif comment_match = latest_comment_url.match(/comments\/(\d+?)$/)
      comment_id = comment_match[1]
      client.issue_comment(repos_owner, comment_id)['html_url']
    else
      nil
    end
  end
end
