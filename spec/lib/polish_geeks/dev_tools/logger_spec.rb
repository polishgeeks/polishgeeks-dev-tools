require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Logger do
  subject(:logger) { described_class.new }

  let(:task) { PolishGeeks::DevTools::Commands::Rubocop.new }
  let(:tmp) { double }

  describe '#log' do
    context 'when we print an output' do
      before do
        expect(task)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:generator?)
          .and_return(true)
        expect(logger)
          .to receive(:info)
          .with(task)
      end

      it 'returns some information' do
        logger.log(task)
      end
    end

    context 'when we print an output with an error' do
      before do
        expect(tmp)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:generator?)
          .and_return(false)
        expect(tmp)
          .to receive(:valid?)
          .and_return(false)
        expect(logger)
          .to receive(:fatal)
          .with(tmp)
      end

      it 'raises RequirementsError' do
        expect { logger.log(tmp) }
          .to raise_error PolishGeeks::DevTools::Errors::RequirementsError
      end
    end
  end

  describe '#info' do
    context 'when we print a final message for a validator' do
      before do
        expect(task)
          .to receive(:label)
          .and_return('Rubocop')
        expect(task)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:generator?)
          .and_return(false)
        expect(task)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:validator?)
          .and_return(true)
      end

      it 'displays "OK" text' do
        expect(logger)
          .to receive(:printf)
          .with('%-50s %2s', 'Rubocop ', "\e[32mOK\e[0m\n")
        logger.send(:info, task)
      end
    end

    context 'when we print a final message for a generator' do
      before do
        expect(task)
          .to receive(:label)
          .and_return('Rubocop')
        expect(task)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:generator?)
          .and_return(true)
        expect(task)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:validator?)
          .and_return(false)
      end

      it 'displays "OK" text' do
        expect(logger)
          .to receive(:printf)
          .with('%-50s %2s', 'Rubocop ', "\e[32mGENERATED\e[0m\n")
        logger.send(:info, task)
      end
    end

    context 'when a task fails' do
      before do
        expect(tmp)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:generator?)
          .and_return(false)
        expect(tmp)
          .to receive(:class)
          .and_return(tmp)
        expect(tmp)
          .to receive(:validator?)
          .and_return(false)
      end

      it 'raises UnknownTaskType' do
        expect { logger.send(:info, tmp) }
          .to raise_error PolishGeeks::DevTools::Errors::UnknownTaskType
      end
    end
  end

  describe '#fatal' do
    context 'when a task failed' do
      before do
        expect(task)
          .to receive(:label)
          .and_return('Rubocop')
        expect(task)
          .to receive(:error_message)
          .and_return('')
      end

      it 'returns a message' do
        expect(logger)
          .to receive(:printf)
          .with('%-30s %20s', 'Rubocop ', "\e[31mFAILURE\e[0m\n\n")
        logger.send(:fatal, task)
      end
    end
  end

  describe '#label' do
    context 'when we get a label for task' do
      before do
        expect(task)
          .to receive(:label)
          .and_return('Rubocop')
      end

      it 'returns the label' do
        expect(logger.send(:label, task)).to eq 'Rubocop'
      end
    end
  end
end
