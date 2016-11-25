require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::TasksFilesNames do
  subject(:tasks_files_names) { described_class.new }

  let(:config) { double }

  describe 'CAP' do
    let(:dirs) { ['lib/capistrano'] }
    let(:regexp) { /.*\.cap$/ }

    it { expect(described_class::CAP.dirs).to eq dirs }
    it { expect(described_class::CAP.regexp).to eq regexp }
  end

  describe 'RAKE' do
    let(:dirs) { ['lib/tasks'] }
    let(:regexp) { /.*\.rake$/ }

    it { expect(described_class::RAKE.dirs).to eq dirs }
    it { expect(described_class::RAKE.regexp).to eq regexp }
  end

  describe '#valid?' do
    before do
      tasks_files_names.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }

      it { expect(tasks_files_names.valid?).to eq true }
    end

    context 'when output is not empty' do
      let(:output) { ['file_name'] }

      it { expect(tasks_files_names.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(1000) }
    let(:expected) { "Tasks files names: #{counter} files checked" }

    before do
      tasks_files_names.instance_variable_set('@counter', counter)
    end

    it { expect(tasks_files_names.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files have invalid extensions: \n #{output.join("\n")}\n" }

    before do
      tasks_files_names.instance_variable_set('@output', output)
    end

    it { expect(tasks_files_names.error_message).to eq expected }
  end

  describe '#files' do
    let(:dummy_type) do
      OpenStruct.new(
        dirs: %w(lib)
      )
    end

    it 'does not be empty' do
      expect(tasks_files_names.send(:files, dummy_type)).not_to be_empty
    end

    it 'does not contain directories' do
      expect(tasks_files_names.send(:files, dummy_type)).not_to include('command')
    end
  end

  describe '#execute' do
    let(:example_cap_files) { %w(a b c test.cap) }
    let(:example_rake_files) { %w(d e f test.rake) }

    before do
      expect(tasks_files_names)
        .to receive(:files)
        .with(described_class::CAP)
        .and_return(example_cap_files.dup)

      expect(tasks_files_names)
        .to receive(:files)
        .with(described_class::RAKE)
        .and_return(example_rake_files.dup)

      tasks_files_names.execute
    end

    it 'sets counter' do
      expect(
        tasks_files_names.counter
      ).to eq example_cap_files.count + example_rake_files.count
    end

    it { expect(tasks_files_names.output).not_to include('test.cap') }
    it { expect(tasks_files_names.output).not_to include('test.rake') }
  end
end
