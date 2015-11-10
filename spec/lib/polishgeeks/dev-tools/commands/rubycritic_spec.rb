require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Rubycritic do
  subject { described_class.new }

  describe '#execute' do
    context 'when we run rubycritic' do
      before do
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with('bundle exec rubycritic ./app ./lib/')
      end

      it 'should execute the command' do
        subject.execute
      end
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq true }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq false }
  end
end
