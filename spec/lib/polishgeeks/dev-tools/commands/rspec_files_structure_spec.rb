require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::RspecFilesStructure do
  subject { described_class.new }

  describe '#execute' do
    let(:analyzed_files_result) { double }
    let(:rspec_files_result) { double }
    let(:substract_result) { double }
    let(:substract_rspec_result) { double }
    let(:expected) { Hash(app: substract_result, rspec: substract_rspec_result) }

    before do
      expect(subject)
        .to receive(:analyzed_files)
        .twice
        .and_return(analyzed_files_result)

      expect(subject)
        .to receive(:rspec_files)
        .exactly(2).times
        .and_return(rspec_files_result)

      expect(analyzed_files_result)
        .to receive(:-)
        .and_return(substract_result)

      expect(rspec_files_result)
        .to receive(:-)
        .and_return(substract_rspec_result)
    end

    it 'should be subtraction' do
      subject.execute

      expect(subject.instance_variable_get(:@output)).to eq expected
    end
  end

  describe '#analyzed_files' do
    let(:config) { double(rspec_files_structure_ignored: nil) }

    before do
      expect(PolishGeeks::DevTools)
        .to receive(:config)
        .and_return(config)
        .at_least(:once)
    end

    it { expect(subject.send(:analyzed_files)).to_not be_empty }

    context 'when we gather files for analyze' do
      let(:file) { double }
      let(:files_collection) { [file] }

      before do
        expect(described_class::FILES_CHECKED)
          .to receive(:map)
          .and_return(files_collection)
      end

      it 'should flatten, uniq and sanitize' do
        expect(files_collection)
          .to receive(:flatten!)

        expect(files_collection)
          .to receive(:uniq!)

        expect(subject)
          .to receive(:sanitize)
          .with(file)

        subject.send(:analyzed_files)
      end
    end
  end

  describe '#rspec_files' do
    let(:config) { double(rspec_files_structure_ignored: nil) }

    before do
      expect(PolishGeeks::DevTools)
        .to receive(:config)
        .and_return(config)
        .at_least(:once)
    end

    it { expect(subject.send(:rspec_files)).to_not be_empty }

    context 'when we gather rspec files' do
      let(:file) { double }
      let(:files_collection) { [file] }

      before do
        expect(described_class::RSPEC_FILES)
          .to receive(:map)
          .and_return(files_collection)
      end

      it 'should flatten, uniq and sanitize' do
        expect(files_collection)
          .to receive(:flatten!)

        expect(files_collection)
          .to receive(:uniq!)

        expect(subject)
          .to receive(:sanitize)
          .with(file)

        subject.send(:rspec_files)
      end
    end
  end

  describe '#valid?' do
    before do
      subject.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { Hash(app: [], rspec: []) }

      it { expect(subject.valid?).to eq true }
    end

    context 'when output is not empty' do
      let(:output) { Hash(app: [double], rspec: [double]) }

      it { expect(subject.valid?).to eq false }
    end
  end

  describe '#label' do
    context 'when we run rspec_files_structure' do
      let(:analyzed_files_result) { double(count: rand(1000)) }

      before do
        expect(subject)
          .to receive(:analyzed_files)
          .and_return(analyzed_files_result)
      end

      it 'should return the label' do
        expected = "Rspec files structure (#{analyzed_files_result.count} checked)"
        expect(subject.label).to eq expected
      end
    end
  end

  describe '#error_message' do
    context 'when files don\'t have corresponding Rspec files' do
      let(:message) { rand.to_s }
      let(:expected) { message + message }
      before do
        expect(subject)
          .to receive(:files_error_message)
          .and_return(message)
        expect(subject)
          .to receive(:rspec_error_message)
          .and_return(message)
      end

      it 'should return the error message' do
        expect(subject.error_message).to eq expected
      end
    end
  end

  describe '#excludes' do
    context 'when rspec_files_structure_ignored is not set' do
      let(:config) { double(rspec_files_structure_ignored: nil) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return(config)
      end

      it { expect(subject.send(:excludes)).to eq [] }
    end

    context 'when rspec_files_structure_ignored is set' do
      let(:rspec_files_structure_ignored) { rand }
      let(:config) do
        double(
          rspec_files_structure_ignored: rspec_files_structure_ignored
        )
      end

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return(config)
      end

      it { expect(subject.send(:excludes)).to eq rspec_files_structure_ignored }
    end
  end

  describe '#sanitize' do
    let(:base) { rand.to_s }

    context 'app root' do
      let(:string) { "#{PolishGeeks::DevTools.app_root}/#{base}" }

      it ' should be removed' do
        expect(subject.send(:sanitize, string)).to eq base
      end
    end

    context '_spec' do
      let(:string) { "#{base}_spec.rb" }

      it ' should be removed' do
        expect(subject.send(:sanitize, string)).to eq "#{base}.rb"
      end
    end

    context 'spec/' do
      let(:string) { "spec/#{base}" }

      it ' should be removed' do
        expect(subject.send(:sanitize, string)).to eq base
      end
    end

    context 'app/' do
      let(:string) { "app/#{base}" }

      it ' should be removed' do
        expect(subject.send(:sanitize, string)).to eq base
      end
    end
  end

  describe '#files_error_message' do
    let(:output) { Hash(app: ['test.rb'], rspec: ['test_rspec.rb']) }

    before do
      subject.instance_variable_set(:@output, output)
    end

    it 'should return the error message' do
      expect(subject.send(:files_error_message))
        .to eq "Following files don't have corresponding Rspec files:\n\ntest.rb\n"
    end
  end

  describe '#rspec_error_message' do
    let(:output) { Hash(app: ['test.rb'], rspec: ['test_rspec.rb']) }

    before do
      subject.instance_variable_set(:@output, output)
    end

    it 'should return the error message' do
      expect(subject.send(:rspec_error_message))
        .to eq "\n\nFollowing Rspec don't have corresponding files:\n\ntest_rspec_spec.rb\n"
    end
  end
end
