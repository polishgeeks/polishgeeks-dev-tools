require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Logger do
  subject { described_class.new }

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
        expect(subject)
          .to receive(:info)
          .with(task)
      end

      it 'should return some information' do
        subject.log(task)
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
        expect(subject)
          .to receive(:fatal)
          .with(tmp)
      end

      it 'should raise RequirementsError' do
        expect { subject.log(tmp) }
          .to raise_error PolishGeeks::DevTools::Logger::RequirementsError
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

      it 'should display "OK" text' do
        expect(subject)
          .to receive(:printf)
          .with('%-40s %2s', 'Rubocop ', "\e[32mOK\e[0m\n")
        subject.send(:info, task)
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

      it 'should display "OK" text' do
        expect(subject)
          .to receive(:printf)
          .with('%-40s %2s', 'Rubocop ', "\e[32mGENERATED\e[0m\n")
        subject.send(:info, task)
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

      it 'should raise UnknownTaskType' do
        expect { subject.send(:info, tmp) }
          .to raise_error PolishGeeks::DevTools::Logger::UnknownTaskType
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

      it 'should return a message' do
        expect(subject)
          .to receive(:printf)
          .with('%-30s %20s', 'Rubocop ', "\e[31mFAILURE\e[0m\n\n")
        subject.send(:fatal, task)
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

      it 'should return the label' do
        expect(subject.send(:label, task)).to eq 'Rubocop'
      end
    end
  end
end
