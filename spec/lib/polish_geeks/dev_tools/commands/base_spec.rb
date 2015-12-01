require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Base do
  subject { described_class.new }

  describe '#execute' do
    let(:error) { PolishGeeks::DevTools::Errors::NotImplementedError }
    it { expect { subject.execute }. to raise_error(error) }
  end

  describe '#valid?' do
    let(:error) { PolishGeeks::DevTools::Errors::NotImplementedError }
    it { expect { subject.valid? }. to raise_error(error) }
  end

  describe '#error_message' do
    let(:output) { rand.to_s }

    before do
      subject.instance_variable_set('@output', output)
    end

    it 'by default should equal raw output' do
      expect(subject.error_message).to eq output
    end
  end

  describe '#ensure_executable!' do
    context 'when there are validators' do
      let(:validator_class) { PolishGeeks::DevTools::Validators::Base }

      before do
        expect(described_class)
          .to receive(:validators)
          .and_return([validator_class])

        expect_any_instance_of(validator_class)
          .to receive(:valid?)
          .and_return(true)
      end

      it { expect { subject.ensure_executable! }.not_to raise_error }
    end

    context 'when we dont require any validators' do
      before do
        expect(described_class)
          .to receive(:validators)
          .and_return([])
      end

      it { expect { subject.ensure_executable! }.not_to raise_error }
    end
  end

  describe '#config?' do
    context 'when application config exist' do
      before { allow(subject).to receive(:app_config?) { true } }
      it { expect(subject.config?).to be true }
    end

    context 'when application config does not exist' do
      before { allow(subject).to receive(:app_config?) { false } }
      context 'and local config exist' do
        before { allow(subject).to receive(:local_config?) { true } }
        it { expect(subject.config?).to be true }
      end

      context 'and local config does not exist' do
        before { allow(subject).to receive(:local_config?) { false } }
        it { expect(subject.config?).to be false }
      end
    end
  end

  describe '#config' do
    let(:path) { '/path/to/config' }
    context 'when application config exist' do
      before do
        allow(subject).to receive(:app_config?) { true }
        expect(subject).to receive(:app_config) { path }
      end
      it { expect(subject.config).to eq path }
    end

    context 'when application config does not exist' do
      let(:path2) { '/path/to/config2' }
      before do
        allow(subject).to receive(:app_config?) { false }
        expect(subject).to receive(:app_config).never
        expect(subject).to receive(:local_config) { path2 }
      end
      it { expect(subject.config).to be path2 }
    end
  end

  describe '#local_config?' do
    context 'when config name present' do
      let(:path) { '/path/to/config' }

      before do
        subject.class.config_name = '.rubocop.yml'
        allow(PolishGeeks::DevTools).to receive(:gem_root) { path }
      end

      context 'and file exist' do
        before { expect(File).to receive(:exist?).with(subject.send(:local_config)) { true } }
        it { expect(subject.send(:local_config?)).to be true }
      end

      context 'and file does not exist' do
        before { expect(File).to receive(:exist?).with(subject.send(:local_config)) { false } }
        it { expect(subject.send(:local_config?)).to be false }
      end
    end

    context 'when config name not present' do
      before { subject.class.config_name = nil }
      it { expect(subject.send(:local_config?)).to be false }
    end
  end

  describe '#local_config' do
    let(:path) { '/path/to/config' }
    let(:config_name) { '.rubocop.yml' }

    before do
      subject.class.config_name = config_name
      allow(PolishGeeks::DevTools).to receive(:gem_root) { path }
    end

    it { expect(subject.send(:local_config)).to eq(File.join(path, 'config', config_name)) }
  end

  describe '#app_config?' do
    context 'when config name present' do
      let(:path) { '/path/to/config' }

      before do
        subject.class.config_name = '.rubocop.yml'
        allow(PolishGeeks::DevTools).to receive(:app_root) { path }
      end

      context 'and file exist' do
        before { expect(File).to receive(:exist?).with(subject.send(:app_config)) { true } }
        it { expect(subject.send(:app_config?)).to be true }
      end

      context 'and file does not exist' do
        before { expect(File).to receive(:exist?).with(subject.send(:app_config)) { false } }
        it { expect(subject.send(:app_config?)).to be false }
      end
    end

    context 'when config name not present' do
      before { subject.class.config_name = nil }
      it { expect(subject.send(:app_config?)).to be false }
    end
  end

  describe '#app_config' do
    let(:path) { '/path/to/config' }
    let(:config_name) { '.rubocop.yml' }

    before do
      subject.class.config_name = config_name
      allow(PolishGeeks::DevTools).to receive(:app_root) { path }
    end

    it { expect(subject.send(:app_config)).to eq(File.join(path, config_name)) }
  end

  describe '#files_from_path' do
    let(:app_root) { PolishGeeks::DevTools.app_root }

    context 'path is a directory' do
      let(:path) { rand.to_s }
      let(:file_in_path) { "#{app_root}/#{rand}" }
      let(:dir_in_path) { "#{app_root}/#{rand}" }
      before do
        expect(File)
          .to receive(:file?)
          .with("#{app_root}/#{path}")
          .and_return(false)

        expect(Dir)
          .to receive(:glob)
          .with("#{app_root}/#{path}")
          .and_return([file_in_path, dir_in_path])

        expect(File)
          .to receive(:file?)
          .with(file_in_path)
          .and_return(true)

        expect(File)
          .to receive(:file?)
          .with(dir_in_path)
          .and_return(false)
      end
      it { expect(subject.send(:files_from_path, path)).to eq [file_in_path] }
    end

    context 'path is a file' do
      let(:path) { rand.to_s }
      before do
        expect(File)
          .to receive(:file?)
          .with("#{app_root}/#{path}")
          .and_return(true)
      end
      it { expect(subject.send(:files_from_path, path)).to eq ["#{app_root}/#{path}"] }
    end
  end
end
