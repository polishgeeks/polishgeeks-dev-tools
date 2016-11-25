require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::BundlerAudit do
  subject(:bundler_audit) { described_class.new }

  describe '#execute' do
    let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }

    before do
      allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
      expect(instance).to receive(:execute)
        .with('bundle-audit update 2>&1 > /dev/null; bundle-audit check')
    end

    it { bundler_audit.execute }
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
        bundler_audit.instance_variable_set('@output', output)
      end

      it { expect(bundler_audit.valid?).to eq false }
    end

    context 'when there are no vulnerabilities' do
      before { bundler_audit.instance_variable_set('@output', 'No vulnerabilities found') }

      it { expect(bundler_audit.valid?).to eq true }
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
