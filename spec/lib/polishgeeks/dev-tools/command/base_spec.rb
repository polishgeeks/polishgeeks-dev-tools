require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Command::Base do
  subject { described_class.new }

  describe '#execute' do
    let(:error) { PolishGeeks::DevTools::Errors::NotImplementedError }
    it { expect { subject.execute }. to raise_error(error) }
  end

  describe '#valid?' do
    let(:error) { PolishGeeks::DevTools::Errors::NotImplementedError }
    it { expect { subject.valid? }. to raise_error(error) }
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
    before { expect_any_instance_of(described_class).to receive(:prepare_validators) }

    it { described_class.new }
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

  describe '#validation!' do
    context 'when valid validator' do
      it { expect { subject.validation! }.not_to raise_error }
    end

    context 'when invalid validator' do
      before { subject.class.validators = ['Invalid'] }
      it do
        expect { subject.validation! }.to raise_error(
          PolishGeeks::DevTools::Errors::InvalidValidatorClassError
        )
      end
    end
  end
end
