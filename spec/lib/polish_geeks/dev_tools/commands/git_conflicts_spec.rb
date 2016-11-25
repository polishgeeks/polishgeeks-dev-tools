require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::GitConflicts do
  describe '#execute' do
    before do
      expect(subject)
        .to receive(:invalid_files)
        .and_return(invalid_files)

      subject.execute
    end

    context 'when all files are valid' do
      let(:invalid_files) { [] }

      it 'sets output as an empty array' do
        expect(subject.output).to eq []
      end
    end

    context 'when exist not valid file' do
      let(:invalid_files) { [rand.to_s, rand.to_s] }

      it 'sets output as an array with invalid files' do
        expect(subject.output).to eq invalid_files
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
    let(:expected) { 'Git conflicts' }

    before do
      subject.instance_variable_set('@counter', counter)
    end

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files have git conflicts: \n#{output.join("\n")}\n" }

    before do
      subject.instance_variable_set('@output', output)
    end

    it { expect(subject.error_message).to eq expected }
  end

  describe '#invalid_files' do
    let(:cmd_result) { "travis.yml\nREADME.md\n" }
    let(:shell) { double }

    before do
      expect(PolishGeeks::DevTools::Shell)
        .to receive(:new)
        .and_return(shell)

      expect(shell)
        .to receive(:execute)
        .with("grep -r -l '#{described_class::CHECKED_REGEXP}' . | xargs -n1 basename")
        .and_return(cmd_result)
    end

    it { expect(subject.send(:invalid_files)).to eq ['travis.yml', 'README.md'] }
  end
end
