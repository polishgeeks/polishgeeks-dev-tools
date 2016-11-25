require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Rspec do
  subject(:rspec) { described_class.new }

  describe '#execute' do
    let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }

    context 'when we run rspec' do
      before do
        allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
        expect(instance).to receive(:execute)
          .with('bundle exec rspec spec')
      end

      it { rspec.execute }
    end
  end

  describe '#valid?' do
    context 'when there is 1 failure' do
      before { rspec.instance_variable_set(:@output, '1 failure') }

      it { expect(rspec.valid?).to eq false }
    end

    context 'when there are failures' do
      before { rspec.instance_variable_set(:@output, '2 failures') }

      it { expect(rspec.valid?).to eq false }
    end

    context 'when there are no failures' do
      before { rspec.instance_variable_set(:@output, '0 failures') }

      it { expect(rspec.valid?).to eq true }
    end

    context 'when there are no failures' do
      let(:config) { double }

      context 'and disallow pending false' do
        before do
          expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
          expect(config).to receive(:rspec_disallow_pending?) { false }
          rspec.instance_variable_set(:@output, '0 failures, 2 pending')
        end

        it { expect(rspec.valid?).to eq true }
      end

      context 'and disallow pending true' do
        before do
          expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
          expect(config).to receive(:rspec_disallow_pending?) { true }
        end

        context 'and there are pendings' do
          before do
            rspec.instance_variable_set(:@output, '0 failures, 2 pending')
          end

          it { expect(rspec.valid?).to eq false }
        end

        context 'and there are no pendings' do
          before do
            rspec.instance_variable_set(:@output, '0 failures, 0 pending')
          end

          it { expect(rspec.valid?).to eq true }
        end
      end
    end
  end

  describe '#label' do
    context 'when we run rspec' do
      let(:label) { '10 examples, 5 failures, 2 pending' }

      before { rspec.instance_variable_set(:@output, label) }

      it { expect(rspec.label).to eq 'Rspec (10 ex, 5 fa, 2 pe)' }
    end
  end

  describe '#examples_count' do
    before { rspec.instance_variable_set(:@output, '10 examples') }

    it { expect(rspec.send(:examples_count)).to eq(10) }
  end

  describe '#failures_count' do
    before { rspec.instance_variable_set(:@output, '10 failures') }

    it { expect(rspec.send(:failures_count)).to eq(10) }
  end

  describe '#pending_count' do
    before { rspec.instance_variable_set(:@output, '10 pending') }

    it { expect(rspec.send(:pending_count)).to eq(10) }
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
