require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Validators::Rubocop do
  subject { described_class.new(double) }

  describe '#valid?' do
    context 'false' do
      context 'when Rubocop is enabled' do
        before do
          expect(PolishGeeks::DevTools::Config).to receive(:config).and_return(
            instance_double(PolishGeeks::DevTools::Config, rubocop: false)
          )
        end
        it { expect(subject.valid?).to be false }
      end
    end

    context 'true' do
      context 'when Rubocop is disabled' do
        before do
          expect(PolishGeeks::DevTools::Config).to receive(:config).and_return(
            instance_double(PolishGeeks::DevTools::Config, rubocop: true)
          )
        end
        it { expect(subject.valid?).to be true }
      end
    end
  end
end
