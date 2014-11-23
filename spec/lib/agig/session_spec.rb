# coding: utf-8
require File.expand_path('../../../spec_helper', __FILE__)
require 'logger'

describe Agig::Session do

  let :log do
    StringIO.new
  end

  let :oauth_token do
    'OAUTH_TOKEN_DUMMY'
  end

  before do
    octokit_client = Octokit::Client.new(oauth_token: oauth_token)
    @session = described_class.new('localhost', nil, Logger.new(log))
    @session.instance_variable_set(:@client, octokit_client)
  end

  describe '#retrieve' do
    let :long_time_ago do
      Time.parse('Jan 1 2010')
    end

    before do
      allow(@session).to receive(:reachable_url_for).and_return('')

      %w(/notifications?all=true /user/received_events).each do |path|
        stub_request(:get, "https://api.github.com#{path}")
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json; charset=utf-8' },
          body: open("#{fixture_path}#{path}.json").read)
      end
    end

    context 'When notifications have not been retrieved for a long time' do
      before do
        @session.instance_variable_set(:@notification_last_retrieved, long_time_ago)
      end

      it do
        expect(@session).to \
          receive(:post).with(anything(), anything(), '#notification', anything())
                        .exactly(5).times
        @session.send(:retrieve, 0)
      end
    end

    context 'When watches have not been retrieved for a long time' do
      before do
        @session.instance_variable_set(:@watch_last_retrieved, long_time_ago)
      end

      it do
        expect(@session).to \
          receive(:post).with(anything(), anything(), '#watch', anything())
                        .exactly(2).times
        @session.send(:retrieve, 0)
      end
    end
  end

  describe '#reachable_url_for' do
    subject { @session.send(:reachable_url_for, latest_comment_url) }

    context 'When "https://api.github.com/repos/fastladder/fastladder/pulls/170" given' do
      before do
        allow(@session).to receive_message_chain(:client, :issue_comments).and_return([])
      end

      let(:latest_comment_url) { 'https://api.github.com/repos/fastladder/fastladder/pulls/170' }
      it { is_expected.to eq('https://github.com/fastladder/fastladder/pull/170') }
    end
  end
end
