require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Command::Base do
  subject { described_class.new }

  describe '#execute' do
    it { expect { subject.execute }. to raise_error(NotImplementedError) }
  end

  describe '#valid?' do
    it { expect { subject.valid? }. to raise_error(NotImplementedError) }
  end

  describe '#error_message' do
    let(:output) { rand.to_s }

    before do
      subject.instance_variable_set('@output', output)
    end

    it 'by default should equal raw output' do
      expect(subject.error_message).to eq output
    end
  end

  describe '#new' do
    it 'should execute ensure_framework_if_required' do
      expect_any_instance_of(described_class)
        .to receive(:ensure_framework_if_required)
        .once

      described_class.new
    end
  end

  describe '#ensure_framework_if_required' do
    context 'when there is no framework required' do
      before { described_class.framework = nil }

      it { expect { subject.send(:ensure_framework_if_required) }.to_not raise_error }
    end

    context 'when there rails is required' do
      before { described_class.framework = :rails }

      context 'and it is included' do
        before do
          expect(PolishGeeks::DevTools)
            .to receive(:config)
            .and_return(double(rails?: true))
            .exactly(2).times
        end

        it { expect { subject.send(:ensure_framework_if_required) }.to_not raise_error }
      end

      context 'and it is not included' do
        before do
          expect(PolishGeeks::DevTools)
            .to receive(:config)
            .and_return(double(rails?: false))
        end

        it 'should raise exception' do
          error = described_class::MissingFramework
          expect { subject.send(:ensure_framework_if_required) }.to raise_error(error, 'rails')
        end
      end
    end

    context 'when there sinatra is required' do
      before { described_class.framework = :sinatra }

      context 'and it is included' do
        before do
          expect(PolishGeeks::DevTools)
            .to receive(:config)
            .and_return(double(sinatra?: true))
            .exactly(2).times
        end

        it { expect { subject.send(:ensure_framework_if_required) }.to_not raise_error }
      end

      context 'and it is not included' do
        before do
          expect(PolishGeeks::DevTools)
            .to receive(:config)
            .and_return(double(sinatra?: false))
        end

        it 'should raise exception' do
          error = described_class::MissingFramework
          expect { subject.send(:ensure_framework_if_required) }.to raise_error(error, 'sinatra')
        end
      end
    end
  end

  describe 'class type definer' do
    subject { described_class.dup }

    context 'when it is generator' do
      before { subject.type = :generator }

      describe '.generator?' do
        it { expect(subject.generator?).to eq true }
      end

      describe '.validator?' do
        it { expect(subject.validator?).to eq false }
      end
    end

    context 'when it is validator' do
      before { subject.type = :validator }

      describe '.generator?' do
        it { expect(subject.generator?).to eq false }
      end

      describe '.validator?' do
        it { expect(subject.validator?).to eq true }
      end
    end
  end
end
