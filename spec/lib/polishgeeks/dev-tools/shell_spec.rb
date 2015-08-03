require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Shell do
  subject { described_class.new }

  describe '#execute' do
    context 'when we run a command' do
      it 'should execute the command' do
        expect(subject.execute('ls')).to include('Gemfile')
      end
    end
  end
end
