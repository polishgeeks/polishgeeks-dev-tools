require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::HamlLint do
  subject(:haml_lint) { described_class.new }

  describe '#execute' do
    let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }
    let(:path) { '/' }

    before do
      expect(ENV).to receive(:[]).with('BUNDLE_GEMFILE') { path }
      allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
    end

    context 'when app config exists' do
      before do
        expect(File).to receive(:exist?) { true }
        expect(instance).to receive(:execute)
          .with("bundle exec haml-lint -c #{path}.haml-lint.yml app/views")
      end

      it { haml_lint.execute }
    end

    context 'when app config does not exist' do
      let(:path) { Dir.pwd }
      before do
        expect(PolishGeeks::DevTools).to receive(:gem_root) { path }
        expect(File).to receive(:exist?) { false }
        expect(instance).to receive(:execute)
          .with("bundle exec haml-lint -c #{path}/config/haml-lint.yml app/views")
      end

      it { haml_lint.execute }
    end
  end

  describe '#valid?' do
    context 'when there are some issues' do
      before do
        haml_lint.instance_variable_set('@output', '[W] SpaceInsideHashAttributes')
      end

      it { expect(haml_lint.valid?).to eq false }
    end

    context 'when there are no issues' do
      before do
        haml_lint.instance_variable_set('@output', '')
      end

      it { expect(haml_lint.valid?).to eq true }
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
