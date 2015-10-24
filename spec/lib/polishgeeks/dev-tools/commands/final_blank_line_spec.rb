require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::FinalBlankLine do
  subject { described_class.new }

  describe '#execute' do
    let(:files) { [rand.to_s, rand.to_s] }

    before do
      expect(subject)
        .to receive(:files_to_analyze)
        .and_return(files)
    end

    context 'when all files are valid' do
      before do
        expect(subject)
          .to receive(:file_valid?)
          .exactly(files.count).times
          .and_return true
        subject.execute
      end

      it 'should set appropriate variables' do
        expect(subject.output).to eq []
        expect(subject.counter).to eq(files.count)
      end
    end

    context 'when exist not valid file' do
      before do
        expect(subject)
          .to receive(:file_valid?)
          .exactly(files.count).times
          .and_return false

        files.each do |file|
          expect(subject)
            .to receive(:sanitize)
            .with(file)
            .and_return(file)
        end
        subject.execute
      end

      it 'should set appropriate variables' do
        expect(subject.output).to eq files
        expect(subject.counter).to eq(files.count)
      end
    end
  end

  describe '#valid?' do
    before do
      subject.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }
      it { expect(subject.valid?).to eq true }
    end

    context 'when output have some files' do
      let(:output) { ['file_name'] }
      it { expect(subject.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(10) }
    let(:expected) { "Final blank line: #{counter} files checked" }

    before do
      subject.instance_variable_set('@counter', counter)
    end

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files don't have final blank line: \n#{output.join("\n")}\n" }

    before do
      subject.instance_variable_set('@output', output)
    end

    it { expect(subject.error_message).to eq expected }
  end

  describe '#files_to_analyze' do
    let(:files) { [rand.to_s, rand.to_s] }

    before do
      expect(subject)
        .to receive(:files_from_path)
        .with('**/{*,.*}')
        .and_return(files)

      expect(subject)
        .to receive(:remove_excludes)
        .with(files)
        .and_return(files)
    end

    it { expect(subject.send(:files_to_analyze)).to eq files }
  end

  describe '#remove_excludes' do
    let(:files) { %w(lib/file.txt exclude.txt file.rb) }
    let(:excludes) { %w(lib exclude.txt) }

    before do
      expect(subject)
        .to receive(:excludes)
        .and_return(excludes)
    end

    it { expect(subject.send(:remove_excludes, files)).to eq ['file.rb'] }
  end

  describe '#excludes' do
    let(:configs) { [rand.to_s] }
    let(:expected) { configs + described_class::DEFAULT_PATHS_TO_EXCLUDE }

    before do
      expect(subject)
        .to receive(:config_excludes)
        .and_return(configs)
    end

    it { expect(subject.send(:excludes)).to eq expected }
  end

  describe '#config_excludes' do
    context 'final_blank_line_ignored is set' do
      let(:paths) { [rand.to_s, rand.to_s] }
      let(:config) { double(final_blank_line_ignored: paths) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config
      end

      it { expect(subject.send(:config_excludes)).to eq paths }
    end

    context 'final_blank_line_ignored is not set' do
      let(:config) { double(final_blank_line_ignored: nil) }
      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config
      end
      it { expect(subject.send(:config_excludes)).to eq [] }
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

  describe '#sanitize' do
    let(:file) { rand.to_s }
    let(:app_root) { PolishGeeks::DevTools.app_root }
    let(:path) { "#{app_root}/#{file}" }

    it { expect(subject.send(:sanitize, "#{app_root}/#{path}")).to eq file }
  end

  describe '#file_valid?' do
    let(:file) { rand.to_s }

    context 'file is not empty' do
      before do
        expect(File)
          .to receive(:size)
          .with(file)
          .and_return(1)
      end

      context 'file has final blank line' do
        before do
          expect(IO)
            .to receive(:readlines)
            .with(file)
            .and_return([rand.to_s + "\n"])
        end

        it { expect(subject.send(:file_valid?, file)).to eq true }
      end

      context 'file does not have final blank line' do
        before do
          expect(IO)
            .to receive(:readlines)
            .with(file)
            .and_return([rand.to_s + 'end'])
        end

        it { expect(subject.send(:file_valid?, file)).to eq false }
      end
    end

    context 'file is empty' do
      before do
        expect(File)
          .to receive(:size?)
          .with(file)
          .and_return(0)

        it { expect(subject.send(:file_valid?, file)).to eq true }
      end
    end
  end
end
