require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Simplecov do
  context 'class' do
    subject(:simplecov) { described_class }

    describe '#validators' do
      it 'works only when we have Simplecov' do
        expect(simplecov.validators).to eq [PolishGeeks::DevTools::Validators::Simplecov]
      end
    end
  end

  context 'instance' do
    subject(:simplecov) { described_class.new }

    let(:label) { '(95.00%) covered' }
    let(:config) { double }

    describe '#to_f' do
      context 'when we run simplecov' do
        before { simplecov.instance_variable_set(:@output, label) }

        it 'returns number of coverage as a float value' do
          expect(simplecov.to_f).to eq 95.00
        end
      end
    end

    describe '#execute' do
      context 'when we run simplecov' do
        let(:output) { OpenStruct.new(rspec: label) }

        before { simplecov.instance_variable_set(:@stored_output, output) }

        it { expect(simplecov.execute).to eq label }
      end
    end

    describe '#valid?' do
      context 'when cc level is greater or equal than expected' do
        before do
          expect(simplecov)
            .to receive(:to_f)
            .and_return(95.0)
          expect(PolishGeeks::DevTools::Config)
            .to receive(:config)
            .and_return(config)
          expect(config)
            .to receive(:simplecov_threshold)
            .and_return(65.0)
        end

        it { expect(simplecov.valid?).to eq true }
      end

      context 'when cc level is less than expected' do
        before do
          expect(simplecov)
            .to receive(:to_f)
            .and_return(65.0)
          expect(PolishGeeks::DevTools::Config)
            .to receive(:config)
            .and_return(config)
          expect(config)
            .to receive(:simplecov_threshold)
            .and_return(95.0)
        end

        it { expect(simplecov.valid?).to eq false }
      end
    end

    describe '#label' do
      context 'when we run simplecov and cc is greater or equal than expected' do
        before do
          expect(simplecov)
            .to receive(:to_f)
            .and_return(95.0)
          expect(PolishGeeks::DevTools::Config)
            .to receive(:config)
            .and_return(config)
          expect(config)
            .to receive(:simplecov_threshold)
            .and_return(65.0)
        end

        it 'returns the label' do
          expect(simplecov.label).to eq 'SimpleCov covered 95.0%, required 65.0%'
        end
      end
    end

    describe '#error_message' do
      context 'when we run simplecov and cc is less than expected' do
        before { allow(simplecov).to receive(:to_f) { 65.0 } }

        context 'and threshold is 95%' do
          before { allow(simplecov).to receive(:threshold) { 95.0 } }

          it 'returns the error message' do
            expect(simplecov.error_message)
              .to eq 'SimpleCov coverage level needs to be 95.0% or more, was 65.0%'
          end
        end

        context 'and threshold is 100%' do
          before { allow(simplecov).to receive(:threshold) { 100.0 } }

          it 'returns the error message' do
            expect(simplecov.error_message)
              .to eq 'SimpleCov coverage level needs to be 100.0%, was 65.0%'
          end
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
end
