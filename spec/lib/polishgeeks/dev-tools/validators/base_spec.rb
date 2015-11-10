require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Base do
  let(:output) { :output }
  subject { described_class.new(output) }

  describe '#new' do
    it { expect(subject.instance_variable_get(:@stored_output)).to eq output }
  end

  describe '#valid?' do
    it do
      expect { subject.valid? }.to raise_error(PolishGeeks::DevTools::Errors::NotImplementedError)
    end
  end

  describe '#validate!' do
    context 'valid? true' do
      before { expect(subject).to receive(:valid?) { true } }

      it { expect { subject.validate! }.not_to raise_error }
    end

    context 'valid? false' do
      before { expect(subject).to receive(:valid?) { false } }

      it do
        expect { subject.validate! }.to raise_error(
          PolishGeeks::DevTools::Errors::PreCommandValidationError
        )
      end
    end
  end
end
