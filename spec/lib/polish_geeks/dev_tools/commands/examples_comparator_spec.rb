require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::ExamplesComparator do
  subject(:examples_comparator) { described_class.new }

  let(:example_file) { rand.to_s }
  let(:dedicated_file) { example_file }
  let(:dedicated_file_present) { true }

  describe '#execute' do
    let(:config_path) { rand.to_s }

    before do
      expect(examples_comparator)
        .to receive(:config_path)
        .and_return(config_path)

      expect(Dir)
        .to receive(:[])
        .with(config_path)
        .and_return([example_file])

      expect(File)
        .to receive(:exist?)
        .with(dedicated_file)
        .and_return(dedicated_file_present)
    end

    context 'when compared files structure is the same' do
      let(:compare_result) { true }

      before do
        expect(examples_comparator)
          .to receive(:same_key_structure?)
          .and_return(compare_result)
      end

      it 'puts a successful message into output' do
        examples_comparator.execute

        expect(examples_comparator.output).to include 'success'
      end
    end

    context 'when compared files structure is not the same' do
      let(:compare_result) { false }

      before do
        expect(examples_comparator)
          .to receive(:same_key_structure?)
          .and_return(compare_result)
      end

      it 'puts a failed message into output' do
        examples_comparator.execute
        expect(examples_comparator.output).to include 'failed'
      end
    end

    context 'when dedicated file is not present' do
      let(:dedicated_file_present) { false }

      it 'puts a failed message into output' do
        examples_comparator.execute
        expect(examples_comparator.output).to include 'file is missing'
      end
    end
  end

  describe '#config_path' do
    let(:expected) do
      "#{File.expand_path(PolishGeeks::DevTools.app_root + '/config')}/**/*.yml.example"
    end

    it 'is equal to expected message' do
      expect(examples_comparator.send(:config_path)).to eq expected
    end
  end

  describe '#successful_compare' do
    let(:compare_header) { rand.to_s }
    let(:expected) { "\e[32m success\e[0m - #{compare_header}\n" }

    it 'is equal to expected message' do
      expect(examples_comparator.send(:successful_compare, compare_header)).to eq expected
    end
  end

  describe '#failed_compare' do
    let(:compare_header) { rand.to_s }
    let(:expected) { "\e[31m failed\e[0m - #{compare_header} - structure not equal\n" }

    it 'is equal to expected message' do
      expect(examples_comparator.send(:failed_compare, compare_header)).to eq expected
    end
  end

  describe '#compare_header' do
    let(:expected) { "#{File.basename(example_file)} and #{File.basename(dedicated_file)}" }

    it 'is equal to expected message' do
      expect(
        examples_comparator.send(:compare_header, example_file, dedicated_file)
      ).to eq expected
    end
  end

  describe '#same_key_structure?' do
    let(:structure1) { double }
    let(:structure2) { double }
    let(:hash) { double }

    before do
      expect(PolishGeeks::DevTools::Hash)
        .to receive(:new)
        .and_return(hash)
        .exactly(2).times

      expect(YAML)
        .to receive(:load_file)
        .with(example_file)
        .and_return(structure1)

      expect(YAML)
        .to receive(:load_file)
        .with(dedicated_file)
        .and_return(structure2)

      expect(hash)
        .to receive(:merge!)
        .exactly(2).times

      expect(hash)
        .to receive(:same_key_structure?)
        .and_return(result)
    end

    context 'when structure is the same' do
      let(:result) { true }

      it do
        expect(
          examples_comparator.send(
            :same_key_structure?,
            example_file,
            dedicated_file
          )
        ).to eq(result)
      end
    end

    context 'when structure is not the same' do
      let(:result) { false }

      it do
        expect(
          examples_comparator.send(
            :same_key_structure?,
            example_file,
            dedicated_file
          )
        ).to eq(result)
      end
    end
  end

  describe '#valid?' do
    context 'when example files have the same structure' do
      before do
        examples_comparator.instance_variable_set(:@output, 'OK')
      end

      it { expect(examples_comparator.valid?).to eq true }
    end

    context 'when example files do not have the same structure' do
      before do
        examples_comparator.instance_variable_set(:@output, 'failed')
      end

      it { expect(examples_comparator.valid?).to eq false }
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
