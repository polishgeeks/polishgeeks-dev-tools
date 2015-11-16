RSpec.describe PolishGeeks::DevTools::Commands::EmptyMethods::StringRefinements do
  using described_class

  describe '#defines_method?' do
    context 'def method' do
      line = '  def method_for_calculation'

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'define_method method without whitespace after' do
      line = '  define_method(:method_for_calculation) do'

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'define_method method symbol definition' do
      line = '  define_method :method_for_calculation do'

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'define_method method with string definition' do
      line = '  define_method ("method_for_calculation") do'

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'define_method method with comment' do
      line = '  define_method (:method_for_calculation) do #comment'

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'define_method method with params' do
      line = '  define_method (:method_for_calculation) do |a, b| '

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'define_method method with params and comment' do
      line = '  define_method (:method_for_calculation) do |a, b| #comment'

      it { expect(line.defines_method?).to be_truthy }
    end

    context 'string that is not method definition' do
      line = '  define_methods(:method_for_calculation) do |a, b| #comment'

      it { expect(line.defines_method?).to be_falsey }
    end

    context 'string that is not method definition' do
      line = '  define_methods (:method_for_calculation) do |a, b| '

      it { expect(line.defines_method?).to be_falsey }
    end
  end

  describe '#one_line_empty_method?' do
    context 'def method' do
      line = '  def method_for_calculation; end'

      it { expect(line.one_line_empty_method?).to be_truthy }
    end

    context 'def method with comment' do
      line = '  def method_for_calculation; end # comment'

      it { expect(line.one_line_empty_method?).to be_truthy }
    end

    context 'define_method method' do
      line = '  define_method :method_for_calculation {} '

      it { expect(line.one_line_empty_method?).to be_truthy }
    end

    context 'define_method method with comment' do
      line = '  define_method(:method_for_calculation) {} # comment'

      it { expect(line.one_line_empty_method?).to be_truthy }
    end

    context 'define_method method with name as string' do
      line = '  define_method "method_for_calculation" {} '

      it { expect(line.one_line_empty_method?).to be_truthy }
    end

    context 'define_method method with block' do
      line = '  define_method :method_for_calculation { |_a, _b| } # comment'

      it { expect(line.one_line_empty_method?).to be_truthy }
    end

    context 'define_method method with block' do
      line = '  define_method :method_for_calculation { |_a, _b| "5" } # comment'

      it { expect(line.one_line_empty_method?).to be_falsey }
    end

    context 'not empty define_method method' do
      line = '  define_method :method_for_calculation { 5 } # comment'

      it { expect(line.one_line_empty_method?).to be_falsey }
    end

    context 'not empty def method' do
      line = '  def method_for_calculation;  5 end # comment'

      it { expect(line.one_line_empty_method?).to be_falsey }
    end
  end

  describe '#defines_end?' do
    context 'end' do
      line = 'end'

      it { expect(line.defines_end?).to be_truthy }
    end

    context 'end with method call' do
      line = 'end.compact'

      it { expect(line.defines_end?).to be_truthy }
    end

    context 'end with comment' do
      line = 'end.compact # compacts result array'

      it { expect(line.defines_end?).to be_truthy }
    end

    context 'end is commented' do
      line = '# end'

      it { expect(line.defines_end?).to be_falsey }
    end

    context 'similar words' do
      line = 'ends'

      it { expect(line.defines_end?).to be_falsey }
    end
  end

  describe '#not_commented_or_empty?' do
    context 'empty line' do
      line = '  '

      it { expect(line.not_commented_or_empty?).to be_falsey }
    end

    context 'commented line' do
      line = ' # commented line '

      it { expect(line.not_commented_or_empty?).to be_falsey }
    end

    context 'commented line' do
      line = ' line '

      it { expect(line.not_commented_or_empty?).to be_truthy }
    end
  end
end
