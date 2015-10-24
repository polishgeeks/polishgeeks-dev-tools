require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Brakeman do
  subject { described_class.new }

  describe '#execute' do
    context 'when we run brakeman' do
      before do
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with('bundle exec brakeman -q')
      end

      it 'should execute the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when warnings are equal 0' do
      before do
        expect(subject)
          .to receive(:warnings)
          .and_return(0)
      end

      context 'and errors are equal 0' do
        before do
          expect(subject)
            .to receive(:errors)
            .and_return(0)
        end

        it 'should return true' do
          expect(subject.valid?).to eq true
        end
      end

      context 'and errors are not equal 0' do
        before do
          expect(subject)
            .to receive(:errors)
            .and_return(1)
        end

        it 'should return true' do
          expect(subject.valid?).to eq false
        end
      end
    end
  end

  describe 'label' do
    let(:models) { rand(1000) }
    let(:controllers) { rand(1000) }
    let(:templates) { rand(1000) }

    before do
      expect(subject).to receive(:models).and_return(models)
      expect(subject).to receive(:controllers).and_return(controllers)
      expect(subject).to receive(:templates).and_return(templates)
    end

    it 'should use details' do
      label = "Brakeman (#{controllers} con, #{models} mod, #{templates} temp)"
      expect(subject.label).to eq label
    end
  end

  describe 'counter' do
    described_class::REGEXPS.each do |name, _regexp|
      describe "##{name}" do
        let(:amount) { rand(1000) }

        before do
          subject.instance_variable_set(:@output, "#{name.to_s.capitalize} #{amount}")
        end

        it 'should return a proper value' do
          expect(subject.send(name)).to eq amount
        end
      end
    end
  end
end
