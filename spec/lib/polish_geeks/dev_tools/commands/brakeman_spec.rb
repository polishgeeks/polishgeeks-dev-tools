require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Brakeman do
  context 'class' do
    subject(:brakeman) { described_class }

    describe '#validators' do
      it 'works only when we have Rails framework' do
        expect(brakeman.validators).to eq [PolishGeeks::DevTools::Validators::Rails]
      end
    end
  end

  context 'instance' do
    subject(:brakeman) { described_class.new }

    describe '#execute' do
      context 'when we run brakeman' do
        let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }

        before do
          allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
          expect(instance).to receive(:execute).with('bundle exec brakeman -q')
        end

        it { brakeman.execute }
      end
    end

    describe '#valid?' do
      context 'when warnings are equal 0' do
        before do
          expect(brakeman)
            .to receive(:warnings)
            .and_return(0)
        end

        context 'and errors are equal 0' do
          before do
            expect(brakeman)
              .to receive(:errors)
              .and_return(0)
          end

          it { expect(brakeman.valid?).to eq true }
        end

        context 'and errors are not equal 0' do
          before do
            expect(brakeman)
              .to receive(:errors)
              .and_return(1)
          end

          it { expect(brakeman.valid?).to eq false }
        end
      end
    end

    describe 'label' do
      let(:models) { rand(1000) }
      let(:controllers) { rand(1000) }
      let(:templates) { rand(1000) }

      before do
        expect(brakeman).to receive(:models).and_return(models)
        expect(brakeman).to receive(:controllers).and_return(controllers)
        expect(brakeman).to receive(:templates).and_return(templates)
      end

      it 'uses details' do
        label = "Brakeman (#{controllers} con, #{models} mod, #{templates} temp)"
        expect(brakeman.label).to eq label
      end
    end

    describe 'counter' do
      described_class::REGEXPS.each do |name, _regexp|
        describe "##{name}" do
          let(:amount) { rand(1000) }

          before do
            brakeman.instance_variable_set(:@output, "#{name.to_s.capitalize} #{amount}")
          end

          it 'returns a proper value' do
            expect(brakeman.send(name)).to eq amount
          end
        end
      end
    end
  end
end
