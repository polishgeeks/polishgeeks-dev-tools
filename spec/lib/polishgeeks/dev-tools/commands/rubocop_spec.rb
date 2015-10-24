require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Rubocop do
  subject { described_class.new }

  describe '#execute' do
    let(:path) { '/' }
    before do
      expect(ENV)
        .to receive(:[])
        .with('BUNDLE_GEMFILE')
        .and_return(path)
        .at_least(:once)
    end

    context 'when app config exists' do
      before do
        expect(File)
          .to receive(:exist?)
          .and_return(true)
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with("bundle exec rubocop -c #{path}.rubocop.yml #{PolishGeeks::DevTools.app_root}")
      end

      it 'should execute the command' do
        subject.execute
      end
    end

    context 'when app config does not exist' do
      let(:path) { Dir.pwd }
      let(:app_root) { PolishGeeks::DevTools.app_root }
      let(:cmd_expected) { "bundle exec rubocop -c #{path}/config/rubocop.yml #{app_root}" }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:gem_root)
          .and_return(path)
        expect(File)
          .to receive(:exist?)
          .and_return(false)
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with(cmd_expected)
      end

      it 'should execute the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when offenses count is equal 0' do
      before do
        expect(subject)
          .to receive(:offenses_count)
          .and_return(0)
      end

      it 'should return true' do
        expect(subject.valid?).to eq true
      end
    end

    context 'when offenses count is different from 0' do
      before do
        expect(subject)
          .to receive(:offenses_count)
          .and_return(100)
      end

      it 'should return false' do
        expect(subject.valid?).to eq false
      end
    end
  end

  describe '#label' do
    context 'when we run rubocop' do
      before do
        expect(subject)
          .to receive(:files_count)
          .and_return(10)
        expect(subject)
          .to receive(:offenses_count)
          .and_return(5)
      end
      it 'should return the label' do
        expect(subject.label).to eq 'Rubocop (10 files, 5 offenses)'
      end
    end
  end

  describe '#files_count' do
    context 'when we count files' do
      before do
        subject.instance_variable_set(:@output, '10 files inspected')
      end

      it 'should return a proper value' do
        expect(subject.send(:files_count)).to eq 10
      end
    end
  end

  describe '#offenses_count' do
    context 'when we count offenses' do
      before do
        subject.instance_variable_set(:@output, '5 offenses detected')
      end

      it 'should return a proper value' do
        expect(subject.send(:offenses_count)).to eq 5
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
