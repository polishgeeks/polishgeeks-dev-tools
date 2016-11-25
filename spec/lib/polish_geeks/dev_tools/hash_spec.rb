require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Hash do
  describe 'same_key_structure?' do
    subject(:hash) { h1.same_key_structure?(h2) }

    context 'when both are empty' do
      let(:h1) { described_class.new }
      let(:h2) { described_class.new }

      it { expect(hash).to be true }
    end

    context 'when first hash is not equal to second' do
      context 'on the first level' do
        let(:h1) { described_class.new.merge(a: 1) }
        let(:h2) { described_class.new.merge(b: 1) }

        it { expect(hash).to be false }
      end

      context 'on the second level' do
        let(:h1) { described_class.new.merge(a: { b: 2 }) }
        let(:h2) { described_class.new.merge(a: { c: 3 }) }

        it { expect(hash).to be false }
      end
    end

    context 'when they have same structure but different data' do
      let(:h1) { described_class.new.merge(a: { b: rand }) }
      let(:h2) { described_class.new.merge(a: { b: rand }) }

      it { expect(hash).to be true }
    end
  end
end
