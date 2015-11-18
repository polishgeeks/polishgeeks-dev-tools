require 'spec_helper'

RSpec.describe PolishGeeks::DevTools do
  subject { described_class }

  it { should be_const_defined(:VERSION) }
end
