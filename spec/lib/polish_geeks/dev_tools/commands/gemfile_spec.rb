require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Gemfile do
  subject { described_class.new }

  describe '#execute' do
    let(:wrong_gem) { rand.to_s }
    let(:gemfile) { double }
    let(:output) { [rand.to_s] }

    before do
      expect(File)
        .to receive(:join)
        .with(::PolishGeeks::DevTools.app_root, 'Gemfile')
        .and_return(gemfile)
    end

    context 'gemfile file exists' do
      before do
        expect(File)
          .to receive(:exist?)
          .with(gemfile)
          .and_return(true)

        expect(IO)
          .to receive(:readlines)
          .with(gemfile)
          .and_return([wrong_gem])

        expect(wrong_gem)
          .to receive(:match)
          .with(described_class::CHECKED_REGEXP)
          .and_return(true)
      end

      it 'set wrong gems to output' do
        subject.execute
        expect(subject.output).to eq [wrong_gem]
      end
    end

    context 'gemfile file does not exist' do
      before do
        expect(File)
          .to receive(:exist?)
          .with(gemfile)
          .and_return(false)
      end

      it 'set empty array to output' do
        subject.execute
        expect(subject.output).to eq []
      end
    end
  end

  describe '#label' do
    it { expect(subject.label).to eq 'Gemfile checking' }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }

    before do
      subject.instance_variable_set('@output', output)
    end

    it 'contains output with wrong gems' do
      expect(subject.error_message)
        .to eq "Gemfile contains gems from local path: \n#{output.join('')}"
    end
  end

  describe '#valid?' do
    context 'when output is empty' do
      before do
        subject.instance_variable_set('@output', [])
      end

      it { expect(subject.valid?).to be true }
    end

    context 'when output is not empty' do
      before do
        subject.instance_variable_set('@output', [rand.to_s])
      end

      it { expect(subject.valid?).to be false }
    end
  end
end
