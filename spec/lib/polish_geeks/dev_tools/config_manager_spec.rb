require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::ConfigManager do
  subject(:config_manager) { described_class.new(name) }
  let(:name) { 'rubocop.yml' }
  let(:path) { '/path/to/config' }

  describe '#present?' do
    context 'when application config exist' do
      before { allow(config_manager).to receive(:application?) { true } }
      it { expect(config_manager.present?).to be true }
    end

    context 'when application config does not exist' do
      before { allow(config_manager).to receive(:application?) { false } }
      context 'and local config exist' do
        before { allow(config_manager).to receive(:local?) { true } }
        it { expect(config_manager.present?).to be true }
      end

      context 'and local config does not exist' do
        before { allow(config_manager).to receive(:local?) { false } }
        it { expect(config_manager.present?).to be false }
      end
    end
  end

  describe '#path' do
    context 'when application config exist' do
      before do
        allow(config_manager).to receive(:application?) { true }
        expect(config_manager).to receive(:application_path) { path }
      end
      it { expect(config_manager.path).to eq path }
    end

    context 'when application config does not exist' do
      let(:path2) { '/path/to/config2' }
      before do
        allow(config_manager).to receive(:application?) { false }
        expect(config_manager).to receive(:application_path).never
        expect(config_manager).to receive(:local_path) { path2 }
      end
      it { expect(config_manager.path).to be path2 }
    end
  end

  describe '#local?' do
    context 'when config name present' do
      before do
        allow(PolishGeeks::DevTools).to receive(:gem_root) { path }
      end

      context 'and file exist' do
        before { expect(config_manager).to receive(:local_path) { path } }
        it { expect(config_manager.send(:local?)).to be true }
      end

      context 'and file does not exist' do
        before { expect(config_manager).to receive(:local_path) { nil } }
        it { expect(config_manager.send(:local?)).to be false }
      end
    end

    context 'when config name not present' do
      subject(:config_manager) { described_class.new(nil) }
      it { expect(config_manager.send(:local?)).to be false }
    end
  end

  describe '#local_path' do
    before do
      allow(PolishGeeks::DevTools).to receive(:gem_root) { path }
      expect(config_manager).to receive(:fetch_path).with(path) { path }
    end

    it { expect(config_manager.send(:local_path)).to eq(path) }
  end

  describe '#application?' do
    context 'when config name present' do
      before do
        allow(PolishGeeks::DevTools).to receive(:app_root) { path }
      end

      context 'and file exist' do
        before { expect(config_manager).to receive(:application_path) { path } }
        it { expect(config_manager.send(:application?)).to be true }
      end

      context 'and file does not exist' do
        before { expect(config_manager).to receive(:application_path) { nil } }
        it { expect(config_manager.send(:application?)).to be false }
      end
    end

    context 'when config name not present' do
      subject(:config_manager) { described_class.new(nil) }
      it { expect(config_manager.send(:application?)).to be false }
    end
  end

  describe '#application_path' do
    before do
      allow(PolishGeeks::DevTools).to receive(:app_root) { path }
      expect(config_manager).to receive(:fetch_path).with(path) { path }
    end

    it { expect(config_manager.send(:application_path)).to eq(path) }
  end

  describe '#fetch_path' do
    let(:config_file) { File.join(path, name) }

    context 'file exist' do
      before { expect(File).to receive(:exist?).with(config_file) { true } }
      it { expect(config_manager.send(:fetch_path, path)).to eq(config_file) }
    end

    context 'file does not exist' do
      it { expect(config_manager.send(:fetch_path, path)).to be nil }
    end
  end
end
