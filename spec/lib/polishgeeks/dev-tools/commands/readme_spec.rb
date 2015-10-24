require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Readme do
  subject { described_class.new }

  let(:config) { double }

  describe '#execute' do
    it 'should execute the command' do
      subject.execute
    end
  end

  describe '#label' do
    let(:expected) { 'README.rb required' }

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:expected) { "README.rb doesn't exist!" }
    let(:output) { false }

    it { expect(subject.error_message).to eq expected }
  end

  describe '#valid?' do
    context 'when README.md exist' do
      before do
        subject.instance_variable_set('@output', true)
      end

      it 'should return true' do
        expect(subject.valid?).to be true
      end
    end
  end
end
