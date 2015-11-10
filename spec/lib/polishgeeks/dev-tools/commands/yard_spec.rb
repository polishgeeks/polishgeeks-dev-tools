require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Yard do
  subject { described_class.new }

  describe '#execute' do
    context 'when we run yard' do
      before do
        expect(subject)
          .to receive(:options)
          .and_return('--list-undoc')
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with('bundle exec yard stats --list-undoc')
      end

      it 'should execute the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when everything is documented and without warnings' do
      before do
        subject.instance_variable_set(:@output, 'OK')
      end

      it 'should return true' do
        expect(subject.valid?).to eq true
      end
    end

    context 'when something has some warnings' do
      before do
        subject.instance_variable_set(:@output, 'warn')
      end

      it 'should return false' do
        expect(subject.valid?).to eq false
      end
    end

    context 'when something is undocumented' do
      before do
        subject.instance_variable_set(:@output, 'undocumented objects')
      end

      it 'should return false' do
        expect(subject.valid?).to eq false
      end
    end
  end

  describe '#options' do
    context 'when we load yard settings' do
      let(:path) { Dir.pwd }
      let(:config) { double }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:gem_root)
          .and_return(path)
        expect(File)
          .to receive(:readlines)
          .and_return(config)
        expect(config)
          .to receive(:join)
          .with(' ')
          .and_return('--private')
      end

      it 'should return lines with options' do
        expect(subject.send(:options)).to eq '--private --list-undoc'
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
