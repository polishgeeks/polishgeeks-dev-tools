require 'spec_helper'

RSpec.describe PolishGeeks::DevTools do
  it { is_expected.to be_const_defined(:VERSION) }
end
