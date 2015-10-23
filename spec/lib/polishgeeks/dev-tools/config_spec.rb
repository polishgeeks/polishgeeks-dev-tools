require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Config do
  subject { described_class.new }

  described_class::COMMANDS.each do |attribute|
    describe "#{attribute}=" do
      let(:value) { rand }
      before { subject.public_send(:"#{attribute}=", value) }

      it 'should assign a given value' do
        expect(subject.public_send(attribute)).to eq value
      end
    end

    describe "#{attribute}?" do
      let(:value) { rand(2) == 0 }
      before { subject.public_send(:"#{attribute}=", value) }

      it 'should assign a given value' do
        expect(subject.public_send(:"#{attribute}?")).to eq value
      end
    end
  end

  describe '.setup' do
    subject { described_class }
    let(:instance) { described_class.new }
    let(:block) { -> {} }

    before do
      instance

      expect(subject)
        .to receive(:new)
        .and_return(instance)

      expect(block)
        .to receive(:call)
        .with(instance)

      expect(instance)
        .to receive(:freeze)
    end

    it { subject.setup(&block) }
  end

  describe '#initialize' do
    described_class::COMMANDS.each do |attribute|
      it "should have #{attribute} command turned on by default" do
        expect(subject.public_send(attribute)).to eq true
      end
    end

    it 'should have simplecov_threshold set to 100 by default' do
      expect(subject.simplecov_threshold).to eq 100
    end
  end
end
