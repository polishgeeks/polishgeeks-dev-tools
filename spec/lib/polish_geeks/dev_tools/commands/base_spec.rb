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
      let(:instance) { instance_double(PolishGeeks::DevTools::Validators::Base) }

      before do
        expect(described_class).to receive(:validators) { [validator_class] }
        allow(validator_class).to receive(:new) { instance }
        expect(instance).to receive(:validate!) { true }
      end

      it { expect { subject.ensure_executable! }.not_to raise_error }
    end

    context 'when we dont require any validators' do
      before { expect(described_class).to receive(:validators) { [] } }
      it { expect { subject.ensure_executable! }.not_to raise_error }
    end
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
