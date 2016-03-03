require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::HamlLint do
  subject { described_class.new }

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

      it 'executes the command' do
        subject.execute
      end
    end

    context 'when app config does not exist' do
      let(:path) { Dir.pwd }
      before do
        expect(PolishGeeks::DevTools).to receive(:gem_root) { path }
        expect(File).to receive(:exist?) { false }
        expect(instance).to receive(:execute)
          .with("bundle exec haml-lint -c #{path}/config/haml-lint.yml app/views")
      end

      it 'executes the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when there are some issues' do
      before do
        subject.instance_variable_set('@output', '[W] SpaceInsideHashAttributes')
      end

      it 'is false' do
        expect(subject.valid?).to eq false
      end
    end

    context 'when there are no issues' do
      before do
        subject.instance_variable_set('@output', '')
      end

      it 'is true' do
        expect(subject.valid?).to eq true
      end
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end
