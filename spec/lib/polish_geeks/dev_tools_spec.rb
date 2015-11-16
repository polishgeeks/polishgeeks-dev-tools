require 'spec_helper'

RSpec.describe PolishGeeks::DevTools do
  subject { described_class }

  describe '.gem_root' do
    context 'when we want to get gem root path' do
      let(:path) { Dir.pwd }
      it do
        expect(subject.gem_root).to eq path
      end
    end
  end

  describe '.app_root' do
    context 'when we want to get app root path' do
      before do
        expect(ENV).to receive(:[]).with('BUNDLE_GEMFILE').and_return('/')
      end

      it { expect(subject.app_root).to eq '/' }
    end
  end

  describe '.setup' do
    let(:config_block) { -> {} }

    it 'passes it to Config setup method' do
      expect(described_class::Config)
        .to receive(:setup)

      subject.setup(&config_block)
    end
  end
end
