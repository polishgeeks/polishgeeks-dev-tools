require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Errors do
  describe 'BaseError' do
    subject { described_class::BaseError }

    specify { expect(subject).to be < StandardError }
  end

  describe 'NotImplementedError' do
    subject { described_class::NotImplementedError }

    specify { expect(subject).to be < described_class::BaseError }
  end
end
