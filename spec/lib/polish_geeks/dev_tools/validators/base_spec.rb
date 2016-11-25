require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Base do
  subject(:base) { described_class.new(output) }
  let(:output) { :output }

  describe '#new' do
    it { expect(base.instance_variable_get(:@stored_output)).to eq output }
  end

  describe '#valid?' do
    it do
      expect { base.valid? }.to raise_error(PolishGeeks::DevTools::Errors::NotImplementedError)
    end
  end

  describe '#validate!' do
    context 'valid? true' do
      before { expect(base).to receive(:valid?) { true } }

      it { expect { base.validate! }.not_to raise_error }
    end

    context 'valid? false' do
      before { expect(base).to receive(:valid?) { false } }

      it do
        expect { base.validate! }.to raise_error(
          PolishGeeks::DevTools::Errors::PreCommandValidationError
        )
      end
    end
  end
end
