require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Simplecov do
  let(:output) do
    OpenStruct.new(
      rspec: '370 / 669 LOC (95.00%) covered'
    )
  end
  subject { described_class.new(output) }

  describe '#valid?' do
    subject do
      described_class.new(
        OpenStruct.new(
          rspec: 'output'
        )
      )
    end

    context 'false' do
      context 'when SimpleCov not defined' do
        before { allow(Object).to receive(:const_defined?) { false } }
        it do
          expect(subject).to receive(:output)
          expect(subject.valid?).to be false
        end
      end
    end

    context 'true' do
      context 'when SimpleCov defined' do
        before { allow(Object).to receive(:const_defined?) { true } }
        it do
          expect(subject).not_to receive(:output)
          expect(subject.valid?).to be true
        end
      end
    end
  end

  describe '#output' do
    it { expect(subject.output).to eq('(95.00%) covered') }
  end
end
