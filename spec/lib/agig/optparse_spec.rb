# coding: utf-8
require File.expand_path('../../../spec_helper', __FILE__)

describe Agig::OptParser do

  describe '#self.cast' do
    let(:opts) { { host: "localhost" } }
    subject { Agig::OptParser.cast opts }

    context 'when string given' do
      it { expect(subject[:host]).to be_an_instance_of String }
    end
    context 'when digit in first letter given' do
      let(:opts) { { port: "16705" } }
      it { expect(subject[:port]).to be_an_instance_of Fixnum }
    end
    context 'when decimal in first letter given' do
      let(:opts) { { interval: "60.5" } }
      it { expect(subject[:interval]).to be_an_instance_of Float }
    end
    context 'when nil given' do
      let(:opts) { { log: nil } }
      it { expect(subject[:log]).to be_falsey }
    end
    context 'when true given' do
      let(:opts) { { debug: true } }
      it { expect(subject[:debug]).to be_truthy }
    end
    context 'when false given' do
      let(:opts) { { foreground: false } }
      it { expect(subject[:foreground]).to be_falsey }
    end
  end

end
