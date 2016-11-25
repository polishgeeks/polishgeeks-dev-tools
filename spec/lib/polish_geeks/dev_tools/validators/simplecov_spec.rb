require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Simplecov do
  subject(:simplecov) { described_class.new(output) }
  let(:output) do
    OpenStruct.new(
      rspec: '370 / 669 LOC (95.00%) covered'
    )
  end

  describe '#valid?' do
    subject(:simplecov) do
      described_class.new(
        OpenStruct.new(
          rspec: 'output'
        )
      )
    end

    context 'false' do
      context 'when SimpleCov not defined' do
        before do
          allow(Object).to receive(:const_defined?) { false }
          expect(simplecov).to receive(:output)
        end
        it { expect(simplecov.valid?).to be false }
      end
    end

    context 'true' do
      context 'when SimpleCov defined' do
        before do
          allow(Object).to receive(:const_defined?) { true }
          expect(simplecov).not_to receive(:output)
        end

        it { expect(simplecov.valid?).to be true }
      end
    end
  end

  describe '#output' do
    it { expect(simplecov.output).to eq('(95.00%) covered') }
  end
end
