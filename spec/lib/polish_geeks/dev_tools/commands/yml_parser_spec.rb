require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::YmlParser do
  subject(:yml_parser) { described_class.new }

  let(:config) { double }
  let(:file) { rand.to_s }
  let(:line) { rand.to_s }
  let(:row) { { file: file, lines: [line] } }

  describe '#execute' do
    let(:results) { [file] }
    let(:json) { { key: 'test', value: 'test' } }
    before do
      expect(Dir)
        .to receive(:[])
        .and_return(results)
      expect(yml_parser)
        .to receive(:parse_yaml)
        .with(file)
        .and_return(json)
      expect(yml_parser)
        .to receive(:check_params)
        .and_return(json)
    end

    it { yml_parser.execute }
  end

  describe '#label' do
    it { expect(yml_parser.label).to eq 'Yaml parser' }
  end

  describe '#error_message' do
    let(:output) { [file: file, lines: [line]] }
    let(:expected) { "Following yml files have nil as a value:\n#{file}:\n - Key '#{line}'\n" }
    before do
      yml_parser.instance_variable_set('@output', output)
    end

    it 'returns lines with nil value' do
      expect(yml_parser.error_message).to eq expected
    end
  end

  describe '#valid?' do
    before { yml_parser.instance_variable_set('@output', '') }

    it { expect(yml_parser.valid?).to eq true }
  end

  describe '#file_error' do
    let(:expected) { "\n#{file}:\n - Key '#{line}'" }

    it { expect(yml_parser.send(:file_error, row)).to eq expected }
  end

  describe '#config_path' do
    let(:expected) { '/**/*.yml.example' }
    before do
      expect(File)
        .to receive(:expand_path)
        .and_return('')
    end
    it { expect(yml_parser.send(:config_path)).to eq expected }
  end

  describe '#sanitize' do
    let(:file_path) { PolishGeeks::DevTools.app_root + '/config/' + file }

    it { expect(yml_parser.send(:sanitize, file_path)).to eq file }
  end

  describe '#parse_yaml' do
    before do
      expect(File)
        .to receive(:open)
        .with(file)
        .and_return(file)
      expect(YAML)
        .to receive(:load)
        .and_return(file)
    end
    it { expect(yml_parser.send(:parse_yaml, file)).to eq file }
  end

  describe '#check_params' do
    context 'when file have nil value' do
      let(:hash) { { key: 'my_key', val: { user: 'test', pass: nil } } }

      it { expect(yml_parser.send(:check_params, hash)).to eq [:pass] }
    end

    context 'when file have not nil value' do
      let(:hash) { { key: 'key', val: 'val' } }

      it { expect(yml_parser.send(:check_params, hash)).to be_empty }
    end
  end
end
