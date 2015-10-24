require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::TasksFilesNames do
  subject { described_class.new }

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
      subject.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }

      it { expect(subject.valid?).to eq true }
    end

    context 'when output is not empty' do
      let(:output) { ['file_name'] }

      it { expect(subject.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(1000) }
    let(:expected) { "Tasks files names: #{counter} files checked" }

    before do
      subject.instance_variable_set('@counter', counter)
    end

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files have invalid extensions: \n #{output.join("\n")}\n" }

    before do
      subject.instance_variable_set('@output', output)
    end

    it { expect(subject.error_message).to eq expected }
  end

  describe '#files' do
    let(:dummy_type) do
      OpenStruct.new(
        dirs: %w( lib )
      )
    end

    it 'should not be empty' do
      expect(subject.send(:files, dummy_type)).to_not be_empty
    end

    it 'should not contain directories' do
      expect(subject.send(:files, dummy_type)).to_not include('command')
    end
  end

  describe '#execute' do
    let(:example_cap_files) { %w( a b c test.cap ) }
    let(:example_rake_files) { %w( d e f test.rake ) }

    before do
      expect(subject)
        .to receive(:files)
        .with(described_class::CAP)
        .and_return(example_cap_files)

      expect(subject)
        .to receive(:files)
        .with(described_class::RAKE)
        .and_return(example_rake_files)
    end

    it 'should set counter' do
      expected = example_cap_files.count + example_rake_files.count
      subject.execute
      expect(subject.counter).to eq expected
    end

    it 'should mark all inapropriate files' do
      subject.execute
      expect(subject.output).to_not include('test.cap')
      expect(subject.output).to_not include('test.rake')
    end
  end
end
