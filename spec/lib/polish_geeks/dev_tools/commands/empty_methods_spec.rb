require 'spec_helper'
require 'tempfile'

RSpec.describe PolishGeeks::DevTools::Commands::EmptyMethods do
  subject { described_class.new }
  describe '#execute' do
    let(:file) { [rand.to_s] }

    before do
      expect(subject)
        .to receive(:files_to_analyze)
        .and_return(file)
      allow(described_class::FileParser)
        .to receive_message_chain(:new, :find_empty_methods)
        .and_return(empty_methods)
    end

    context 'when all files are valid' do
      let(:empty_methods) { [] }
      before do
        subject.execute
      end

      it 'sets appropriate variables' do
        expect(subject.output).to eq []
        expect(subject.counter).to eq(file.count)
      end
    end

    context 'when exist not valid file' do
      let(:empty_methods) { [rand.to_s, rand.to_s] }
      before do
        expect(subject)
          .to receive(:sanitize)
          .with(file.first)
          .and_return(file.first)
        subject.execute
      end

      it 'sets appropriate variables' do
        expect(subject.output.first).to eq "#{file.first} lines #{empty_methods}"
        expect(subject.counter).to eq(file.count)
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
    let(:expected) { "Empty methods: #{counter} files checked" }

    before do
      subject.instance_variable_set('@counter', counter)
    end

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files contains blank methods: \n#{output.join("\n")}\n" }

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
        .with('**/*.rb')
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
    context 'empty_methods_ignored is set' do
      let(:paths) { ["#{rand}.rb", "#{rand}.rb"] }
      let(:config) { double(empty_methods_ignored: paths) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config
      end

      it { expect(subject.send(:config_excludes)).to eq paths }
    end

    context 'empty_methods_ignored is not set' do
      let(:config) { double(empty_methods_ignored: nil) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config
      end

      it { expect(subject.send(:config_excludes)).to eq [] }
    end
  end
end
