require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Rubycritic do
  subject(:rubycritic) { described_class.new }

  describe '#execute' do
    let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }

    context 'when we run rubycritic' do
      before do
        allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
        expect(instance).to receive(:execute)
          .with('bundle exec rubycritic ./app ./lib/')
      end

      it { rubycritic.execute }
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq true }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq false }
  end
end
