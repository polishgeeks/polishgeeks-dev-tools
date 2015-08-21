require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Command::FinalBlankLine do
  subject { described_class.new }

  describe '#execute' do
    let(:not_empty_file) { rand.to_s }
    let(:empty_file) { rand.to_s }
    let(:files_to_analyze) { [not_empty_file, empty_file] }

    before do
      expect(subject)
        .to receive(:files_to_analyze)
        .and_return(files_to_analyze)

      expect(File)
        .to receive(:size)
        .with(not_empty_file)
        .and_return(1)

      expect(File)
        .to receive(:size)
        .with(empty_file)
        .and_return(0)
    end

    context 'when all files have blank final line' do
      before do
        expect(IO)
          .to receive(:readlines)
          .with(not_empty_file)
          .and_return([rand.to_s + "\n"])
        subject.execute
      end

      it 'should set appropriate variables' do
        expect(subject.output).to eq []
        expect(subject.counter).to eq(files_to_analyze.count)
      end
    end

    context 'when exist files without blank final line' do
      before do
        expect(IO)
          .to receive(:readlines)
          .with(not_empty_file)
          .and_return([rand.to_s + 'end'])
        subject.execute
      end

      it 'should set appropriate variables' do
        expect(subject.output).to eq [not_empty_file]
        expect(subject.counter).to eq(files_to_analyze.count)
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
    let(:excludes) { [files[0]] }
    let(:expected) { [files[1]] }

    before do
      expect(subject)
        .to receive(:files_from_path)
        .with('**/{*,.*}')
        .and_return(files)

      expect(subject)
        .to receive(:excludes)
        .and_return(excludes)
    end

    it { expect(subject.send(:files_to_analyze)).to eq expected }
  end

  describe '#excludes' do
    let(:defaults) { [rand.to_s, rand.to_s] }
    let(:configs) { [rand.to_s] }
    let(:expected) { (defaults + configs).flatten }

    before do
      expect(subject)
        .to receive(:default_excludes)
        .and_return(defaults)

      expect(subject)
        .to receive(:config_excludes)
        .and_return(configs)
    end

    it { expect(subject.send(:excludes)).to eq expected }
  end

  describe '#default_excludes' do
    before do
      described_class::DEFAULT_PATHS_TO_EXCLUDE.each do |path|
        expect(subject)
          .to receive(:files_from_path)
          .with("#{path}/**/{*,.*}")
          .and_return(path)
      end
    end

    it { expect(subject.send(:default_excludes)).to eq described_class::DEFAULT_PATHS_TO_EXCLUDE }
  end

  describe '#config_excludes' do
    context 'final_blank_line_ignored is set' do
      let(:file_path) { rand.to_s }
      let(:directory_path) { rand.to_s }
      let(:file_in_directory) { rand.to_s }
      let(:paths) { [file_path, directory_path] }
      let(:config) { double(final_blank_line_ignored: paths) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config

        expect(File)
          .to receive(:file?)
          .with(file_path)
          .and_return(true)

        expect(File)
          .to receive(:file?)
          .with(directory_path)
          .and_return(false)

        expect(subject)
          .to receive(:files_from_path)
          .with(directory_path)
          .and_return(file_in_directory)
      end

      it { expect(subject.send(:config_excludes)).to eq [file_path, file_in_directory] }
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
    let(:path) { rand.to_s }
    let(:file) { rand.to_s }
    let(:dir) { rand.to_s }

    before do
      expect(Dir)
        .to receive(:glob)
        .with(path)
        .and_return([file, dir])

      expect(File)
        .to receive(:file?)
        .with(file)
        .and_return(true)

      expect(File)
        .to receive(:file?)
        .with(dir)
        .and_return(false)
    end

    it { expect(subject.send(:files_from_path, path)).to eq [file] }
  end
end