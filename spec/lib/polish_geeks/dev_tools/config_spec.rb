require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Config do
  subject(:config) { described_class.new }

  described_class::COMMANDS.each do |attribute|
    describe "#{attribute}=" do
      let(:value) { rand }
      before { config.public_send(:"#{attribute}=", value) }

      it 'assigns a given value' do
        expect(config.public_send(attribute)).to eq value
      end
    end

    describe "#{attribute}?" do
      let(:value) { rand(2) == 0 }
      before { config.public_send(:"#{attribute}=", value) }

      it 'assigns a given value' do
        expect(config.public_send(:"#{attribute}?")).to eq value
      end
    end
  end

  describe '.setup' do
    subject(:config) { described_class }
    let(:instance) { described_class.new }
    let(:block) { -> {} }

    before do
      instance

      expect(config)
        .to receive(:new)
        .and_return(instance)

      expect(block)
        .to receive(:call)
        .with(instance)

      expect(instance)
        .to receive(:freeze)
    end

    it { config.setup(&block) }
  end

  describe '#initialize' do
    described_class::COMMANDS.each do |attribute|
      it "should have #{attribute} command turned on by default" do
        expect(config.public_send(attribute)).to eq true
      end
    end

    it 'has simplecov_threshold set to 100 by default' do
      expect(config.simplecov_threshold).to eq 100
    end
  end
end
