require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::OutputStorer do
  subject { described_class.new }

  describe '#initialize' do
    context 'when we execute the command' do
      let(:commands) { %i(rubocop yard) }
      let(:result) { { rubocop: '', yard: '' } }

      before do
        stub_const('PolishGeeks::DevTools::Config::COMMANDS', commands)
      end

      it 'stores an output' do
        expect(subject.send(:initialize)).to eq result
      end
    end
  end
end
