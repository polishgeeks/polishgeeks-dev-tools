require 'spec_helper'

RSpec.describe PolishGeeks::DevTools do
  subject(:dev_tools) { described_class }

  describe '.gem_root' do
    context 'when we want to get gem root path' do
      let(:path) { Dir.pwd }
      it { expect(dev_tools.gem_root).to eq path }
    end
  end

  describe '.app_root' do
    context 'when we want to get app root path' do
      before { expect(ENV).to receive(:[]).with('BUNDLE_GEMFILE').and_return('/') }
      it { expect(dev_tools.app_root).to eq '/' }
    end
  end

  describe '.setup' do
    let(:config_block) { -> {} }

    before { expect(described_class::Config).to receive(:setup) }

    it 'passes it to Config setup method' do
      dev_tools.setup(&config_block)
    end
  end
end
