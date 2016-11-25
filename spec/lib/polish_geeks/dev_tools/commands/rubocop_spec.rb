require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Rubocop do
  subject(:rubocop) { described_class.new }
  let(:config) { double }
  before { allow(PolishGeeks::DevTools::Config).to receive(:config) { config } }

  describe '#execute' do
    let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }
    let(:path) { '/' }

    before do
      expect(ENV)
        .to receive(:[])
        .with('BUNDLE_GEMFILE')
        .and_return(path)
        .at_least(:once)
      allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
    end

    context 'when app config exists' do
      let(:cmd) do
        "bundle exec rubocop #{PolishGeeks::DevTools.app_root}" \
        " -c #{rubocop.class.config_manager.path}" \
        ' --require rubocop-rspec' \
        ' --display-cop-names'
      end

      before do
        expect(config).to receive(:rubocop_rspec?) { true }
        allow(rubocop.class.config_manager).to receive(:application?) { true }
        allow(rubocop.class.config_manager).to receive(:application_path) { path }
        expect(instance).to receive(:execute).with(cmd)
      end

      it { rubocop.execute }
    end

    context 'when app config does not exist' do
      let(:path) { Dir.pwd }
      let(:cmd) do
        "bundle exec rubocop #{PolishGeeks::DevTools.app_root} " \
        "-c #{rubocop.class.config_manager.path} " \
        '--display-cop-names'
      end

      before do
        allow(PolishGeeks::DevTools).to receive(:gem_root).and_return(path)
        expect(config).to receive(:rubocop_rspec?) { false }
        allow(rubocop.class.config_manager).to receive(:application?) { false }
        allow(rubocop.class.config_manager).to receive(:local_path) { path }
        expect(instance).to receive(:execute).with(cmd)
      end

      it { rubocop.execute }
    end
  end

  describe '#valid?' do
    context 'when offenses count is equal 0' do
      before do
        expect(rubocop)
          .to receive(:offenses_count)
          .and_return(0)
      end

      it { expect(rubocop.valid?).to eq true }
    end

    context 'when offenses count is different from 0' do
      before do
        expect(rubocop)
          .to receive(:offenses_count)
          .and_return(100)
      end

      it { expect(rubocop.valid?).to eq false }
    end
  end

  describe '#label' do
    before do
      expect(rubocop).to receive(:files_count) { 10 }
      expect(rubocop).to receive(:offenses_count) { 5 }
    end

    context 'when we run rubocop' do
      before { expect(config).to receive(:rubocop_rspec?) { false } }
      it { expect(rubocop.label).to eq 'Rubocop (10 files, 5 offenses)' }
    end

    context 'when we run rubocop with rspec' do
      before { expect(config).to receive(:rubocop_rspec?) { true } }
      it { expect(rubocop.label).to eq 'Rubocop with RSpec (10 files, 5 offenses)' }
    end
  end

  describe '#files_count' do
    context 'when we count files' do
      before do
        rubocop.instance_variable_set(:@output, '10 files inspected')
      end

      it { expect(rubocop.send(:files_count)).to eq 10 }
    end
  end

  describe '#offenses_count' do
    context 'when we count offenses' do
      before do
        rubocop.instance_variable_set(:@output, '5 offenses detected')
      end

      it { expect(rubocop.send(:offenses_count)).to eq 5 }
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
