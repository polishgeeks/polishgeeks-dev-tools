require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::BundlerAudit do
  subject { described_class.new }

  describe '#execute' do
    before do
      expect_any_instance_of(PolishGeeks::DevTools::Shell)
        .to receive(:execute).with('bundle-audit update 2>&1 > /dev/null; bundle-audit check')
    end

    it { subject.execute }
  end

  describe '#valid?' do
    context 'when there are vulnerabilities' do
      before do
        output = <<-EOS
          Name: activesupport
          Version: 3.2.10
          Advisory: OSVDB-91451
          Criticality: High
          URL: http://www.osvdb.org/show/osvdb/91451
          Title: XML Parsing Vulnerability affecting JRuby users
          Solution: upgrade to ~> 3.1.12, >= 3.2.13

          Unpatched versions found!
        EOS
        subject.instance_variable_set('@output', output)
      end

      it { expect(subject.valid?).to eq false }
    end

    context 'when there are no vulnerabilities' do
      before { subject.instance_variable_set('@output', 'No vulnerabilities found') }

      it { expect(subject.valid?).to eq true }
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
