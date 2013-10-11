# coding: utf-8
require File.expand_path('../../../spec_helper', __FILE__)

describe Agig::Session do
  before do
    @session = described_class.new('localhost', nil, nil)
  end

  describe '#reachable_url_for' do
    subject { @session.send(:reachable_url_for, latest_comment_url) }

    context 'When "https://api.github.com/repos/fastladder/fastladder/pulls/170" given' do
      before do
        @session.stub_chain(:client, :issue_comments).and_return([])
      end

      let(:latest_comment_url) { 'https://api.github.com/repos/fastladder/fastladder/pulls/170' }
      it { should eq('https://github.com/fastladder/fastladder/pull/170') }
    end
  end
end
