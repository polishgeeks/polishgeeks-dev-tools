require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Yard do
  subject(:yard) { described_class.new }

  describe '#execute' do
    let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }

    context 'when we run yard' do
      before do
        expect(yard).to receive(:options) { '--list-undoc' }
        allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
        expect(instance).to receive(:execute)
          .with('bundle exec yard stats --list-undoc')
      end

      it { yard.execute }
    end
  end

  describe '#valid?' do
    context 'when everything is documented and without warnings' do
      before { yard.instance_variable_set(:@output, 'OK') }

      it { expect(yard.valid?).to eq true }
    end

    context 'when something has some warnings' do
      before { yard.instance_variable_set(:@output, 'warn') }

      it { expect(yard.valid?).to eq false }
    end

    context 'when something is undocumented' do
      before { yard.instance_variable_set(:@output, 'undocumented objects') }

      it { expect(yard.valid?).to eq false }
    end
  end

  describe '#options' do
    context 'when we load yard settings' do
      let(:path) { Dir.pwd }
      let(:config) { double }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:gem_root)
          .and_return(path)
        expect(File)
          .to receive(:readlines)
          .and_return(config)
        expect(config)
          .to receive(:join)
          .with(' ')
          .and_return('--private')
      end

      it 'returns lines with options' do
        expect(yard.send(:options)).to eq '--private --list-undoc'
      end
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
