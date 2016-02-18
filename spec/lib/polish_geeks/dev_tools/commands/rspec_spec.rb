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

      it { subject.execute }
    end
  end

  describe '#valid?' do
    context 'when there are failures' do
      before { subject.instance_variable_set(:@output, '2 failures') }

      it { expect(subject.valid?).to eq false }
    end

    context 'when there are no failures' do
      before { subject.instance_variable_set(:@output, '0 failures') }

      it { expect(subject.valid?).to eq true }
    end

    context 'when there are no failures' do
      let(:config) { double }

      context 'and disallow pending false' do
        before do
          expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
          expect(config).to receive(:rspec_disallow_pending?) { false }
          subject.instance_variable_set(:@output, '0 failures, 2 pending')
        end

        it { expect(subject.valid?).to eq true }
      end

      context 'and disallow pending true' do
        before do
          expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
          expect(config).to receive(:rspec_disallow_pending?) { true }
        end

        context 'and there are pendings' do
          before do
            subject.instance_variable_set(:@output, '0 failures, 2 pending')
          end

          it { expect(subject.valid?).to eq false }
        end

        context 'and there are no pendings' do
          before do
            subject.instance_variable_set(:@output, '0 failures, 0 pending')
          end

          it { expect(subject.valid?).to eq true }
        end
      end
    end
  end

  describe '#label' do
    context 'when we run rspec' do
      let(:label) { '10 examples, 5 failures, 2 pending' }

      before { subject.instance_variable_set(:@output, label) }

      it { expect(subject.label).to eq 'Rspec (10 ex, 5 fa, 2 pe)' }
    end
  end

  describe '#examples_count' do
    before { subject.instance_variable_set(:@output, '10 examples') }

    it { expect(subject.send(:examples_count)).to eq(10) }
  end

  describe '#failures_count' do
    before { subject.instance_variable_set(:@output, '10 failures') }

    it { expect(subject.send(:failures_count)).to eq(10) }
  end

  describe '#pending_count' do
    before { subject.instance_variable_set(:@output, '10 pending') }

    it { expect(subject.send(:pending_count)).to eq(10) }
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
