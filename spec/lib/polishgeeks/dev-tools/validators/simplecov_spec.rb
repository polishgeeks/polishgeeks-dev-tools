require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Simplecov do
  let(:output) { double(rspec: '370 / 669 LOC (95.00%) covered') }
  subject { described_class.new(output) }

  describe '#valid?' do
    context 'false' do
      subject { described_class.new(double(rspec: 'output')) }
      context 'when SimpleCov not defined' do
        before { allow(Object).to receive(:const_defined?) { false } }
        it do
          expect(subject).to receive(:output)
          expect(subject.valid?).to be false
        end
      end
    end

    context 'true' do
      subject { described_class.new(double(rspec: 'output')) }
      context 'when SimpleCov defined' do
        before { allow(Object).to receive(:const_defined?) { true } }
        it do
          expect(subject).to_not receive(:output)
          expect(subject.valid?).to be true
        end
      end
    end
  end

  describe '#output' do
    it { expect(subject.output).to eq('(95.00%) covered') }
  end
end
