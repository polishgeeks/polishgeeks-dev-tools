require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Errors do
  describe 'BaseError' do
    subject(:errors) { described_class::BaseError }

    specify { expect(errors).to be < StandardError }
  end

  describe 'NotImplementedError' do
    subject(:errors) { described_class::NotImplementedError }

    specify { expect(errors).to be < described_class::BaseError }
  end
end
