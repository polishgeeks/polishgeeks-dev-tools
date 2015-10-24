require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Runner do
  subject { described_class.new }

  describe '#execute' do
    let(:logger) { double }
    let(:output_storer) { double }
    let(:config) { PolishGeeks::DevTools::Config.new }

    before do
      expect(::PolishGeeks::DevTools::OutputStorer)
        .to receive(:new)
        .and_return(output_storer)

      expect(::PolishGeeks::DevTools)
        .to receive(:config)
        .and_return(config)
        .at_least(:once)

      PolishGeeks::DevTools::Config::COMMANDS.each do |command|
        config.public_send(:"#{command}=", true)

        klass_name = command.to_s.gsub(/(?<=_|^)(\w)/, &:upcase).gsub(/(?:_)(\w)/, '\1')
        klass = Object.const_get("PolishGeeks::DevTools::Commands::#{klass_name}")

        instance = double
        output = double

        expect(klass)
          .to receive(:new)
          .and_return(instance)

        expect(instance)
          .to receive(:stored_output=)
          .with(output_storer)

        expect(instance)
          .to receive(:validation!)

        expect(instance)
          .to receive(:execute)

        expect(instance)
          .to receive(:output)
          .and_return(output)

        expect(output_storer)
          .to receive(:"#{command}=")
          .with(output)

        expect(logger)
          .to receive(:log)
          .with(instance)
      end
    end

    it { subject.execute(logger) }
  end
end
