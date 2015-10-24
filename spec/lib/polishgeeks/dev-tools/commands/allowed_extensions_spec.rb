require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::AllowedExtensions do
  subject { described_class.new }

  describe '#execute' do
    let(:file_name) { 'file.rb' }
    let(:files) { [PolishGeeks::DevTools.app_root + '/config/' + file_name] }
    before do
      expect(Dir)
        .to receive(:[])
        .and_return(files)
      expect(described_class::ALLOWED_EXTENSIONS)
        .to receive(:any?)
        .and_return(allow_extension)

      subject.execute
    end

    context 'when we dont have invalid files' do
      let(:allow_extension) { true }
      it { expect(subject.output).to eq [] }
    end

    context 'when we have invalid files' do
      let(:allow_extension) { false }
      it { expect(subject.output).to eq [file_name] }
    end
  end

  describe '#label' do
    let(:expected) { 'Allowed Extensions' }

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) do
      'Following files are not allowed in config directory:'\
      "\n\n#{output.join("\n")}\n"
    end

    before do
      subject.instance_variable_set('@output', output)
    end

    it { expect(subject.error_message).to eq expected }
  end

  describe do
    before do
      subject.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { '' }
      it { expect(subject.valid?).to eq true }
    end

    context 'when output is empty' do
      let(:output) { rand.to_s }
      it { expect(subject.valid?).to eq false }
    end
  end
end
