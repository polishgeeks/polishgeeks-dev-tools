require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::ExpiresIn do
  subject(:expires_in) { described_class.new }

  let(:config) { double }

  describe '#execute' do
    it { expires_in.execute }
  end

  describe '#label' do
    it { expect(expires_in.label).to eq 'Expires in' }
  end

  describe '#error_message' do
    context 'when output is not empty' do
      let(:file_name) { rand.to_s }
      let(:output) { [file_name] }
      let(:expected) { "Following files use expire_in instead of expires_in:\n\n#{file_name}\n" }

      before { expires_in.instance_variable_set('@output', output) }

      it { expect(expires_in.error_message).to eq expected }
    end
  end

  describe '#valid?' do
    context 'when output is empty' do
      before do
        expires_in.instance_variable_set('@output', '')
      end
      it { expect(expires_in.valid?).to eq true }
    end
  end

  describe '#excludes' do
    context 'when expire_files_ignored is not set' do
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          expires_in_files_ignored: nil
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(expires_in.send(:excludes)).to eq [] }
    end

    context 'when expire_files_ignored is set' do
      let(:expires_in_files_ignored) { rand }
      let(:config) do
        instance_double(
          PolishGeeks::DevTools::Config,
          expires_in_files_ignored: expires_in_files_ignored
        )
      end

      before do
        expect(PolishGeeks::DevTools::Config).to receive(:config) { config }
      end

      it { expect(expires_in.send(:excludes)).to eq expires_in_files_ignored }
    end
  end
end
