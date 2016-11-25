require 'spec_helper'
require 'tempfile'

RSpec.describe PolishGeeks::DevTools::Commands::RspecFilesStructure do
  subject(:rspec_files_structure) { described_class.new }

  describe '#execute' do
    let(:analyzed_files_result) { double }
    let(:rspec_files_result) { double }
    let(:substract_result) { double }
    let(:substract_rspec_result) { double }
    let(:expected) { Hash(app: substract_result, rspec: substract_rspec_result) }

    before do
      expect(rspec_files_structure)
        .to receive(:analyzed_files)
        .twice
        .and_return(analyzed_files_result)

      expect(rspec_files_structure)
        .to receive(:analyzed_rspec_files)
        .exactly(2).times
        .and_return(rspec_files_result)

      expect(analyzed_files_result)
        .to receive(:-)
        .and_return(substract_result)

      expect(rspec_files_result)
        .to receive(:-)
        .and_return(substract_rspec_result)

      rspec_files_structure.execute
    end

    it do
      expect(rspec_files_structure.instance_variable_get(:@output)).to eq expected
    end
  end

  describe '#analyzed_files' do
    let(:config) do
      instance_double(
        PolishGeeks::DevTools::Config,
        rspec_files_structure_ignored: nil
      )
    end

    before do
      expect(PolishGeeks::DevTools::Config).to receive(:config).at_least(:once) { config }
    end

    it { expect(rspec_files_structure.send(:analyzed_files)).not_to be_empty }

    context 'when we gather files for analyze' do
      let(:file) { Tempfile.new('tempfile') }
      let(:files_collection) { [file] }

      before do
        expect(rspec_files_structure).to receive(:checked_files) { files_collection }
        expect(files_collection).to receive(:flatten!)
        expect(files_collection).to receive(:uniq!)
        expect(rspec_files_structure).to receive(:sanitize).with(file)
      end

      it 'flatten,s uniq and sanitize' do
        rspec_files_structure.send(:analyzed_files)
      end
    end
  end

  describe '#analyzed_rspec_files' do
    let(:config) do
      instance_double(
        PolishGeeks::DevTools::Config,
        rspec_files_structure_ignored: nil
      )
    end

    before do
      expect(PolishGeeks::DevTools::Config).to receive(:config).at_least(:once) { config }
    end

    it { expect(rspec_files_structure.send(:analyzed_rspec_files)).not_to be_empty }

    context 'when we gather rspec files' do
      let(:file) { double }
      let(:files_collection) { [file] }

      before do
        expect(rspec_files_structure).to receive(:rspec_files) { files_collection }
        expect(files_collection).to receive(:flatten!)
        expect(files_collection).to receive(:uniq!)
        expect(rspec_files_structure).to receive(:sanitize).with(file)
      end

      it 'flatten,s uniq and sanitize' do
        rspec_files_structure.send(:analyzed_rspec_files)
      end
    end
  end

  describe '#valid?' do
    before do
      rspec_files_structure.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { Hash(app: [], rspec: []) }

      it { expect(rspec_files_structure.valid?).to eq true }
    end

    context 'when output is not empty' do
      let(:output) { Hash(app: [double], rspec: [double]) }

      it { expect(rspec_files_structure.valid?).to eq false }
    end
  end

  describe '#label' do
    context 'when we run rspec_files_structure' do
      let(:analyzed_files_result) do
        OpenStruct.new(count: rand(1000))
      end

      before do
        expect(rspec_files_structure).to receive(:analyzed_files) { analyzed_files_result }
      end

      it 'returns the label' do
        expected = "Rspec files structure (#{analyzed_files_result.count} checked)"
        expect(rspec_files_structure.label).to eq expected
      end
    end
  end

  describe '#error_message' do
    context 'when files don\'t have corresponding Rspec files' do
      let(:message) { rand.to_s }
      let(:expected) { message + message }
      before do
        expect(rspec_files_structure)
          .to receive(:files_error_message)
          .and_return(message)
        expect(rspec_files_structure)
          .to receive(:rspec_error_message)
          .and_return(message)
      end

      it 'returns the error message' do
        expect(rspec_files_structure.error_message).to eq expected
      end
    end
  end

  describe '#excludes' do
    context 'when rspec_files_structure_ignored is not set' do
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          rspec_files_structure_ignored: nil
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(rspec_files_structure.send(:excludes)).to eq [] }
    end

    context 'when rspec_files_structure_ignored is set' do
      let(:rspec_files_structure_ignored) { rand }
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          rspec_files_structure_ignored: rspec_files_structure_ignored
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(rspec_files_structure.send(:excludes)).to eq rspec_files_structure_ignored }
    end
  end

  describe '#sanitize' do
    let(:base) { rand.to_s }

    context 'app root' do
      let(:string) { "#{PolishGeeks::DevTools.app_root}/#{base}" }

      it ' should be removed' do
        expect(rspec_files_structure.send(:sanitize, string)).to eq base
      end
    end

    context '_spec' do
      let(:string) { "#{base}_spec.rb" }

      it ' should be removed' do
        expect(rspec_files_structure.send(:sanitize, string)).to eq "#{base}.rb"
      end
    end

    context 'spec/' do
      let(:string) { "spec/#{base}" }

      it ' should be removed' do
        expect(rspec_files_structure.send(:sanitize, string)).to eq base
      end
    end

    context 'app/' do
      let(:string) { "app/#{base}" }

      it ' should be removed' do
        expect(rspec_files_structure.send(:sanitize, string)).to eq base
      end
    end
  end

  describe '#files_error_message' do
    let(:output) { Hash(app: ['test.rb'], rspec: ['test_rspec.rb']) }

    before do
      rspec_files_structure.instance_variable_set(:@output, output)
    end

    it 'returns the error message' do
      expect(rspec_files_structure.send(:files_error_message))
        .to eq "Following files don't have corresponding Rspec files:\n\ntest.rb\n"
    end
  end

  describe '#rspec_error_message' do
    let(:output) { Hash(app: ['test.rb'], rspec: ['test_rspec.rb']) }

    before do
      rspec_files_structure.instance_variable_set(:@output, output)
    end

    it 'returns the error message' do
      expect(rspec_files_structure.send(:rspec_error_message))
        .to eq "\n\nFollowing Rspec don't have corresponding files:\n\ntest_rspec_spec.rb\n"
    end
  end
end
