require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::RequiredFiles do
  subject(:required_files) { described_class.new }

  let(:config) { double }

  describe '#execute' do
    context 'when required_files_include is set' do
      let(:required_files_include) { 'REVIEW.md' }
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          required_files_include: [required_files_include]
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
        required_files.execute
      end

      it { expect(required_files.error_message.match(/REVIEW.md not exist/)).not_to be_nil }
    end

    context 'when required_files_include is empty' do
      it { expect(required_files.error_message).to be_nil }
    end
  end

  describe '#valid?' do
    context 'when file exist' do
      before { required_files.instance_variable_set('@output', []) }

      it { expect(required_files.valid?).to be true }
    end
  end

  describe '#error_message' do
    context 'when output is not empty' do
      let(:file_name) { rand.to_s }
      let(:output) { [file_name] }
      let(:expected) { "Following files does not exist or are empty:\n#{file_name}\n" }
      before do
        required_files.instance_variable_set('@output', output)
      end
      it { expect(required_files.error_message).to eq expected }
    end
  end
end
