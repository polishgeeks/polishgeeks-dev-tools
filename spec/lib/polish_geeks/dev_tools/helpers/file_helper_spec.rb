require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Helpers::FileHelper do
  subject { Object.new.extend(described_class) }

  describe '#sanitize' do
    let(:file) { rand.to_s }
    let(:app_root) { PolishGeeks::DevTools.app_root }
    let(:path) { "#{app_root}/#{file}" }

    it { expect(subject.send(:sanitize, "#{app_root}/#{path}")).to eq file }
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
