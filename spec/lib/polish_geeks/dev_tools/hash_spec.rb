require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Hash do
  describe 'diff' do
    subject { h1.diff(h2) }

    context 'when both are empty' do
      let(:h1) { described_class.new }
      let(:h2) { described_class.new }

      it { expect(subject).to eq({}) }
    end

    context 'when first hash is not equal to second' do
      context 'on the first level' do
        let(:h1) { described_class.new.merge(a: 1) }
        let(:h2) { described_class.new.merge(b: 1) }

        it { expect(subject).to eq(a: [1, nil], b: [nil, 1]) }
      end

      context 'on the second level' do
        let(:h1) { described_class.new.merge(a: { b: 2 }) }
        let(:h2) { described_class.new.merge(a: { c: 3 }) }

        it { expect(subject).to eq(a: { b: [2, nil], c: [nil, 3] }) }
      end

      context 'on the third level' do
        let(:h1) { described_class.new.merge(a: { b: { c: 1 } }) }
        let(:h2) { described_class.new.merge(a: { b: { c: 1, d: 1 }, e: 1 }) }

        it { expect(subject).to eq(a: { e: [nil, 1], b: { d: [nil, 1] } }) }
      end

      context 'across 2 levels' do
        let(:h1) { described_class.new.merge(a: { b: { c: 1, d: 1 }, e: 1 }) }
        let(:h2) { described_class.new.merge(a: { b: nil }) }

        it { expect(subject).to eq(a: { e: [1, nil], b: {:c=>[1, nil], :d=>[1, nil] }}) }
      end
    end

    context 'when they have same structure but different data' do
      let(:h1) { described_class.new.merge(a: { b: rand }) }
      let(:h2) { described_class.new.merge(a: { b: rand }) }

      it { expect(subject).to eq({}) }
    end
  end
end
