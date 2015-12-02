require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::ConfigManager do
  let(:name) { 'rubocop.yml' }
  let(:path) { '/path/to/config' }
  subject { described_class.new(name) }

  describe '#present?' do
    context 'when application config exist' do
      before { allow(subject).to receive(:application?) { true } }
      it { expect(subject.present?).to be true }
    end

    context 'when application config does not exist' do
      before { allow(subject).to receive(:application?) { false } }
      context 'and local config exist' do
        before { allow(subject).to receive(:local?) { true } }
        it { expect(subject.present?).to be true }
      end

      context 'and local config does not exist' do
        before { allow(subject).to receive(:local?) { false } }
        it { expect(subject.present?).to be false }
      end
    end
  end

  describe '#path' do
    context 'when application config exist' do
      before do
        allow(subject).to receive(:application?) { true }
        expect(subject).to receive(:application_path) { path }
      end
      it { expect(subject.path).to eq path }
    end

    context 'when application config does not exist' do
      let(:path2) { '/path/to/config2' }
      before do
        allow(subject).to receive(:application?) { false }
        expect(subject).to receive(:application_path).never
        expect(subject).to receive(:local_path) { path2 }
      end
      it { expect(subject.path).to be path2 }
    end
  end

  describe '#local?' do
    context 'when config name present' do
      before do
        allow(PolishGeeks::DevTools).to receive(:gem_root) { path }
      end

      context 'and file exist' do
        before { expect(subject).to receive(:local_path) { path } }
        it { expect(subject.send(:local?)).to be true }
      end

      context 'and file does not exist' do
        before { expect(subject).to receive(:local_path) { nil } }
        it { expect(subject.send(:local?)).to be false }
      end
    end

    context 'when config name not present' do
      subject { described_class.new(nil) }
      it { expect(subject.send(:local?)).to be false }
    end
  end

  describe '#local_path' do
    before do
      allow(PolishGeeks::DevTools).to receive(:gem_root) { path }
      expect(subject).to receive(:fetch_path).with(path) { path }
    end

    it { expect(subject.send(:local_path)).to eq(path) }
  end

  describe '#application?' do
    context 'when config name present' do
      before do
        allow(PolishGeeks::DevTools).to receive(:app_root) { path }
      end

      context 'and file exist' do
        before { expect(subject).to receive(:application_path) { path } }
        it { expect(subject.send(:application?)).to be true }
      end

      context 'and file does not exist' do
        before { expect(subject).to receive(:application_path) { nil } }
        it { expect(subject.send(:application?)).to be false }
      end
    end

    context 'when config name not present' do
      subject { described_class.new(nil) }
      it { expect(subject.send(:application?)).to be false }
    end
  end

  describe '#application_path' do
    before do
      allow(PolishGeeks::DevTools).to receive(:app_root) { path }
      expect(subject).to receive(:fetch_path).with(path) { path }
    end

    it { expect(subject.send(:application_path)).to eq(path) }
  end

  describe '#fetch_path' do
    let(:config_file) { File.join(path, name) }

    context 'file exist' do
      before { expect(File).to receive(:exist?).with(config_file) { true } }
      it { expect(subject.send(:fetch_path, path)).to eq(config_file) }
    end

    context 'file does not exist' do
      it { expect(subject.send(:fetch_path, path)).to be nil }
    end
  end
end
