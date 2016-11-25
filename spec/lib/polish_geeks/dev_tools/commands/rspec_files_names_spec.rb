require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::RspecFilesNames do
  subject(:rspec_files_names) { described_class.new }

  let(:config) { double }

  describe '#execute' do
    let(:path) { rand.to_s }

    before do
      described_class::CHECKED_DIRS.each do |name|
        expect(File)
          .to receive(:join)
          .with(::PolishGeeks::DevTools.app_root, 'spec', name)
          .and_return(path)
      end

      expect(Dir)
        .to receive(:glob)
        .with("#{path}/**/*")
        .exactly(described_class::CHECKED_DIRS.count).times
        .and_return(files)

      expect(File)
        .to receive(:file?)
        .and_return(true)
        .exactly(described_class::CHECKED_DIRS.count).times

      rspec_files_names.execute
    end

    context 'when we dont have invalid files' do
      let(:files) { ['test_spec.rb'] }

      it { expect(rspec_files_names.output).to eq [] }
      it do
        expect(
          rspec_files_names.counter
        ).to eq(described_class::CHECKED_DIRS.count * files.count)
      end
    end

    context 'when we have invalid files' do
      let(:files) { ['test_spe.rb'] }

      it { expect(rspec_files_names.output).to eq(files * described_class::CHECKED_DIRS.count) }
      it do
        expect(
          rspec_files_names.counter
        ).to eq(described_class::CHECKED_DIRS.count * files.count)
      end
    end
  end

  describe '#valid?' do
    before do
      rspec_files_names.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }

      it { expect(rspec_files_names.valid?).to eq true }
    end

    context 'when output is not empty' do
      let(:output) { ['file_name'] }

      it { expect(rspec_files_names.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(1000) }
    let(:expected) { "Rspec files names: #{counter} files checked" }

    before do
      rspec_files_names.instance_variable_set('@counter', counter)
    end

    it { expect(rspec_files_names.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files have invalid name: \n #{output.join("\n")}\n" }

    before do
      rspec_files_names.instance_variable_set('@output', output)
    end

    it { expect(rspec_files_names.error_message).to eq expected }
  end
end
