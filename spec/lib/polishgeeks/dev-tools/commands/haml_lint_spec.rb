require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::HamlLint do
  subject { described_class.new }

  describe '#execute' do
    let(:path) { '/' }
    before do
      expect(ENV)
        .to receive(:[])
        .with('BUNDLE_GEMFILE')
        .and_return(path)
    end

    context 'when app config exists' do
      before do
        expect(File)
          .to receive(:exist?)
          .and_return(true)
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with("bundle exec haml-lint -c #{path}.haml-lint.yml app/views")
      end

      it 'should execute the command' do
        subject.execute
      end
    end

    context 'when app config does not exist' do
      let(:path) { Dir.pwd }
      before do
        expect(PolishGeeks::DevTools)
          .to receive(:gem_root)
          .and_return(path)
        expect(File)
          .to receive(:exist?)
          .and_return(false)
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with("bundle exec haml-lint -c #{path}/config/haml-lint.yml app/views")
      end

      it 'should execute the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when there are some issues' do
      before do
        subject.instance_variable_set('@output', '[W] SpaceInsideHashAttributes')
      end

      it 'should be false' do
        expect(subject.valid?).to eq false
      end
    end

    context 'when there are no issues' do
      before do
        subject.instance_variable_set('@output', '')
      end

      it 'should be true' do
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
