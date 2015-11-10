require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::ExamplesComparator do
  subject { described_class.new }

  let(:example_file) { rand.to_s }
  let(:dedicated_file) { rand.to_s }

  describe '#execute' do
    let(:config_path) { rand.to_s }

    before do
      expect(subject)
        .to receive(:config_path)
        .and_return(config_path)

      expect(subject)
        .to receive(:same_key_structure?)
        .and_return(compare_result)

      expect(Dir)
        .to receive(:[])
        .with(config_path)
        .and_return([example_file])
    end

    context 'when compared files structure is the same' do
      let(:compare_result) { true }

      it 'should put a successful message into output' do
        subject.execute

        expect(subject.output).to include 'success'
      end
    end

    context 'when compared files structure is not the same' do
      let(:compare_result) { false }

      it 'should put a failed message into output' do
        subject.execute
        expect(subject.output).to include 'failed'
      end
    end
  end

  describe '#config_path' do
    let(:expected) do
      "#{File.expand_path(PolishGeeks::DevTools.app_root + '/config')}/**/*.yml.example"
    end

    it 'should be equal to expected message' do
      expect(subject.send(:config_path)).to eq expected
    end
  end

  describe '#successful_compare' do
    let(:compare_header) { rand.to_s }
    let(:expected) { "\e[32m success\e[0m - #{compare_header}\n" }

    it 'should be equal to expected message' do
      expect(subject.send(:successful_compare, compare_header)).to eq expected
    end
  end

  describe '#failed_compare' do
    let(:compare_header) { rand.to_s }
    let(:expected) { "\e[31m failed\e[0m - #{compare_header} - structure not equal\n" }

    it 'should be equal to expected message' do
      expect(subject.send(:failed_compare, compare_header)).to eq expected
    end
  end

  describe '#compare_header' do
    let(:expected) { "#{File.basename(example_file)} and #{File.basename(dedicated_file)}" }

    it 'should be equal to expected message' do
      expect(subject.send(:compare_header, example_file, dedicated_file)).to eq expected
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

      it '' do
        executed = subject.send(
          :same_key_structure?,
          example_file,
          dedicated_file
        )

        expect(executed).to eq result
      end
    end

    context 'when structure is not the same' do
      let(:result) { false }

      it '' do
        executed = subject.send(
          :same_key_structure?,
          example_file,
          dedicated_file
        )

        expect(executed).to eq result
      end
    end
  end

  describe '#valid?' do
    context 'when example files have the same structure' do
      before do
        subject.instance_variable_set(:@output, 'OK')
      end

      it 'should return true' do
        expect(subject.valid?).to eq true
      end
    end

    context 'when example files do not have the same structure' do
      before do
        subject.instance_variable_set(:@output, 'failed')
      end

      it 'should return false' do
        expect(subject.valid?).to eq false
      end
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
