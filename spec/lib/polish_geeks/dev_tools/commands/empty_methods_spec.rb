require 'spec_helper'
require 'tempfile'

RSpec.describe PolishGeeks::DevTools::Commands::EmptyMethods do
  subject(:empty_methods) { described_class.new }
  describe '#execute' do
    let(:file) { [rand.to_s] }
    let(:empty_methods_output) { [] }

    before do
      expect(empty_methods)
        .to receive(:files_to_analyze)
        .and_return(file)
      allow(described_class::FileParser)
        .to receive_message_chain(:new, :find_empty_methods)
        .and_return(empty_methods_output)
    end

    context 'when all files are valid' do
      before { empty_methods.execute }

      it { expect(empty_methods.output).to eq [] }
      it { expect(empty_methods.counter).to eq(file.count) }
    end

    context 'when exist not valid file' do
      let(:empty_methods_output) { [rand.to_s, rand.to_s] }
      before do
        expect(empty_methods)
          .to receive(:sanitize)
          .with(file.first)
          .and_return(file.first)
        empty_methods.execute
      end

      it { expect(empty_methods.output.first).to eq "#{file.first} lines #{empty_methods_output}" }
      it { expect(empty_methods.counter).to eq(file.count) }
    end
  end

  describe '#valid?' do
    before do
      empty_methods.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }

      it { expect(empty_methods.valid?).to eq true }
    end

    context 'when output have some files' do
      let(:output) { ['file_name'] }

      it { expect(empty_methods.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(10) }
    let(:expected) { "Empty methods: #{counter} files checked" }

    before do
      empty_methods.instance_variable_set('@counter', counter)
    end

    it { expect(empty_methods.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files contains blank methods: \n#{output.join("\n")}\n" }

    before do
      empty_methods.instance_variable_set('@output', output)
    end

    it { expect(empty_methods.error_message).to eq expected }
  end

  describe '#files_to_analyze' do
    let(:files) { [rand.to_s, rand.to_s] }

    before do
      expect(empty_methods)
        .to receive(:files_from_path)
        .with('**/*.rb')
        .and_return(files)

      expect(empty_methods)
        .to receive(:remove_excludes)
        .with(files)
        .and_return(files)
    end

    it { expect(empty_methods.send(:files_to_analyze)).to eq files }
  end

  describe '#remove_excludes' do
    let(:files) { %w(lib/file.txt exclude.txt file.rb) }
    let(:excludes) { %w(lib exclude.txt) }

    before do
      expect(empty_methods)
        .to receive(:excludes)
        .and_return(excludes)
    end

    it { expect(empty_methods.send(:remove_excludes, files)).to eq ['file.rb'] }
  end

  describe '#excludes' do
    let(:configs) { [rand.to_s] }
    let(:expected) { configs + described_class::DEFAULT_PATHS_TO_EXCLUDE }

    before do
      expect(empty_methods)
        .to receive(:config_excludes)
        .and_return(configs)
    end

    it { expect(empty_methods.send(:excludes)).to eq expected }
  end

  describe '#config_excludes' do
    context 'empty_methods_ignored is set' do
      let(:paths) { ["#{rand}.rb", "#{rand}.rb"] }
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          empty_methods_ignored: paths
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(empty_methods.send(:config_excludes)).to eq(paths) }
    end

    context 'empty_methods_ignored is not set' do
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          empty_methods_ignored: nil
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(empty_methods.send(:config_excludes)).to eq [] }
    end
  end

  describe '#sanitize' do
    let(:file) { rand.to_s }
    let(:app_root) { PolishGeeks::DevTools.app_root }
    let(:path) { "#{app_root}/#{file}" }

    it { expect(empty_methods.send(:sanitize, "#{app_root}/#{path}")).to eq file }
  end
end
