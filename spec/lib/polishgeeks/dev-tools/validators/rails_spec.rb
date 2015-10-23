require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Rails do
  subject { described_class.new(double) }

  describe '#valid?' do
    context 'false' do
      context 'when Rails not defined' do
        before { allow(Object).to receive(:const_defined?) { false } }
        it { expect(subject.valid?).to be false }
      end
    end

    context 'true' do
      context 'when Rails defined' do
        before { allow(Object).to receive(:const_defined?) { true } }
        it { expect(subject.valid?).to be true }
      end
    end
  end
end
