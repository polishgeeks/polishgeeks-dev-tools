require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Rspec do
  subject { described_class.new }

  describe '#execute' do
    context 'when we run rspec' do
      before do
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with('bundle exec rspec spec')
      end

      it 'should execute the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when there are some failures' do
      before do
        subject.instance_variable_set(:@output, '2 failures')
      end

      it 'should return false' do
        expect(subject.valid?).to eq false
      end
    end

    context 'when there are not any failures' do
      before do
        subject.instance_variable_set(:@output, '0 failures')
      end

      it 'should return true' do
        expect(subject.valid?).to eq true
      end
    end
  end

  describe '#label' do
    context 'when we run rspec' do
      let(:label) { '10 examples, 5 failures, 2 pending' }

      before do
        subject.instance_variable_set(:@output, label)
      end

      it 'should return the label' do
        expect(subject.label).to eq 'Rspec (10 ex, 5 fa, 2 pe)'
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
