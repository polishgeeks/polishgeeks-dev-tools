require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Command::Simplecov do
  subject { described_class.new }

  let(:label) { '(95.00%) covered' }

  describe '#execute' do
    context 'when we run simplecov' do
      let(:output) { OpenStruct.new(rspec: label) }

      before do
        subject.instance_variable_set(:@stored_output, output)
      end

      it 'should execute the command' do
        expect(subject.execute).to eq label
      end
    end
  end

  describe '#valid?' do
    context 'when a report was generated' do
      before do
        subject.instance_variable_set(:@output, label)
      end

      it 'should return true' do
        expect(subject.valid?).to eq true
      end
    end
  end

  describe '#label' do
    context 'when we run simplecov' do
      before do
        subject.instance_variable_set(:@output, label)
      end

      it 'should return the label' do
        expect(subject.label).to eq 'Simplecov (95.00%) covered'
      end
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
