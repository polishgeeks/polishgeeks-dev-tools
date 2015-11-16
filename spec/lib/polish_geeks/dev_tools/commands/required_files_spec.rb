require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::RequiredFiles do
  subject { described_class.new }

  let(:config) { double }

  describe '#execute' do
    context 'when required_files_include is set' do
      let(:required_files_include) { 'REVIEW.md' }
      let(:config) do
        double(
          required_files_include: [required_files_include]
        )
      end

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return(config)
        subject.execute
      end

      it { expect(subject.error_message.match(/REVIEW.md not exist/)).not_to be_nil }
    end

    context 'when required_files_include is empty' do
      it { expect(subject.error_message).to be_nil }
    end
  end

  describe '#valid?' do
    context 'when file exist' do
      before { subject.instance_variable_set('@output', []) }

      it { expect(subject.valid?).to be true }
    end
  end

  describe '#error_message' do
    context 'when output is not empty' do
      let(:file_name) { rand.to_s }
      let(:output) { [file_name] }
      let(:expected) { "Following files does not exist or are empty:\n#{file_name}\n" }
      before do
        subject.instance_variable_set('@output', output)
      end
      it { expect(subject.error_message).to eq expected }
    end
  end
end
