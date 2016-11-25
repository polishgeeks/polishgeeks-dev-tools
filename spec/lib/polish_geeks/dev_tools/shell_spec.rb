require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Shell do
  subject(:shell) { described_class.new }

  describe '#execute' do
    context 'when we run a command' do
      it 'executes the command' do
        expect(shell.execute('ls')).to include('Gemfile')
      end
    end
  end
end
