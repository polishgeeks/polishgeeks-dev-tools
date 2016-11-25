require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::FinalBlankLine do
  subject(:final_blank_line) { described_class.new }

  describe '#execute' do
    let(:files) { [rand.to_s, rand.to_s] }

    before do
      expect(final_blank_line)
        .to receive(:files_to_analyze)
        .and_return(files)
    end

    context 'when all files are valid' do
      before do
        expect(final_blank_line)
          .to receive(:file_valid?)
          .exactly(files.count).times
          .and_return true
        final_blank_line.execute
      end

      it { expect(final_blank_line.output).to eq [] }
      it { expect(final_blank_line.counter).to eq(files.count) }
    end

    context 'when exist not valid file' do
      before do
        expect(final_blank_line)
          .to receive(:file_valid?)
          .exactly(files.count).times
          .and_return false

        files.each do |file|
          expect(final_blank_line)
            .to receive(:sanitize)
            .with(file)
            .and_return(file)
        end
        final_blank_line.execute
      end

      it { expect(final_blank_line.output).to eq files }
      it { expect(final_blank_line.counter).to eq(files.count) }
    end
  end

  describe '#valid?' do
    before do
      final_blank_line.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }
      it { expect(final_blank_line.valid?).to eq true }
    end

    context 'when output have some files' do
      let(:output) { ['file_name'] }
      it { expect(final_blank_line.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(10) }
    let(:expected) { "Final blank line: #{counter} files checked" }

    before do
      final_blank_line.instance_variable_set('@counter', counter)
    end

    it { expect(final_blank_line.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files don't have final blank line: \n#{output.join("\n")}\n" }

    before do
      final_blank_line.instance_variable_set('@output', output)
    end

    it { expect(final_blank_line.error_message).to eq expected }
  end

  describe '#files_to_analyze' do
    let(:files) { [rand.to_s, rand.to_s] }

    before do
      expect(final_blank_line)
        .to receive(:files_from_path)
        .with('**/{*,.*}')
        .and_return(files)

      expect(final_blank_line)
        .to receive(:remove_excludes)
        .with(files)
        .and_return(files)
    end

    it { expect(final_blank_line.send(:files_to_analyze)).to eq files }
  end

  describe '#remove_excludes' do
    let(:files) { %w(lib/file.txt exclude.txt file.rb) }
    let(:excludes) { %w(lib exclude.txt) }

    before do
      expect(final_blank_line)
        .to receive(:excludes)
        .and_return(excludes)
    end

    it { expect(final_blank_line.send(:remove_excludes, files)).to eq ['file.rb'] }
  end

  describe '#excludes' do
    let(:configs) { [rand.to_s] }
    let(:expected) { configs + described_class::DEFAULT_PATHS_TO_EXCLUDE }

    before do
      expect(final_blank_line)
        .to receive(:config_excludes)
        .and_return(configs)
    end

    it { expect(final_blank_line.send(:excludes)).to eq expected }
  end

  describe '#config_excludes' do
    context 'final_blank_line_ignored is set' do
      let(:paths) { [rand.to_s, rand.to_s] }
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          final_blank_line_ignored: paths
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(final_blank_line.send(:config_excludes)).to eq paths }
    end

    context 'final_blank_line_ignored is not set' do
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          final_blank_line_ignored: nil
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(final_blank_line.send(:config_excludes)).to eq [] }
    end
  end

  describe '#sanitize' do
    let(:file) { rand.to_s }
    let(:app_root) { PolishGeeks::DevTools.app_root }
    let(:path) { "#{app_root}/#{file}" }

    it { expect(final_blank_line.send(:sanitize, "#{app_root}/#{path}")).to eq file }
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

        it { expect(final_blank_line.send(:file_valid?, file)).to eq true }
      end

      context 'file does not have final blank line' do
        before do
          expect(IO)
            .to receive(:readlines)
            .with(file)
            .and_return([rand.to_s + 'end'])
        end

        it { expect(final_blank_line.send(:file_valid?, file)).to eq false }
      end
    end

    context 'file is empty' do
      before do
        expect(File)
          .to receive(:size?)
          .with(file)
          .and_return(0)

        it { expect(final_blank_line.send(:file_valid?, file)).to eq true }
      end
    end
  end
end
