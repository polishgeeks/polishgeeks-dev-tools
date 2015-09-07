require 'spec_helper'
require 'tempfile'

RSpec.describe PolishGeeks::DevTools::Command::EmptyMethod do
  subject { described_class.new }
  describe '#execute' do
    let(:file) { [rand.to_s] }

    before do
      expect(subject)
        .to receive(:files_to_analyze)
        .and_return(file)
      allow(PolishGeeks::DevTools::FileParser)
        .to receive_message_chain(:new, :find_empty_methods)
        .and_return(empty_methods)
    end

    context 'when all files are valid' do
      let(:empty_methods) { [] }
      before do
        subject.execute
      end

      it 'should set appropriate variables' do
        expect(subject.output).to eq []
        expect(subject.counter).to eq(file.count)
      end
    end

    context 'when exist not valid file' do
      let(:empty_methods) { [rand.to_s, rand.to_s] }
      before do
        expect(subject)
          .to receive(:sanitize)
          .with(file.first)
          .and_return(file.first)
        subject.execute
      end

      it 'should set appropriate variables' do
        expect(subject.output.first).to eq "#{file.first} lines #{empty_methods}"
        expect(subject.counter).to eq(file.count)
      end
    end
  end

  describe '#valid?' do
    before do
      subject.instance_variable_set('@output', output)
    end

    context 'when output is empty' do
      let(:output) { [] }

      it { expect(subject.valid?).to eq true }
    end

    context 'when output have some files' do
      let(:output) { ['file_name'] }

      it { expect(subject.valid?).to eq false }
    end
  end

  describe '#label' do
    let(:counter) { rand(10) }
    let(:expected) { "Empty methods: #{counter} files checked" }

    before do
      subject.instance_variable_set('@counter', counter)
    end

    it { expect(subject.label).to eq expected }
  end

  describe '#error_message' do
    let(:output) { [rand.to_s, rand.to_s] }
    let(:expected) { "Following files contains blank methods: \n#{output.join("\n")}\n" }

    before do
      subject.instance_variable_set('@output', output)
    end

    it { expect(subject.error_message).to eq expected }
  end

  describe '#files_to_analyze' do
    let(:files) { [rand.to_s, rand.to_s] }

    before do
      expect(subject)
        .to receive(:files_from_path)
        .with('**/*.rb')
        .and_return(files)

      expect(subject)
        .to receive(:remove_excludes)
        .with(files)
        .and_return(files)
    end

    it { expect(subject.send(:files_to_analyze)).to eq files }
  end

  describe '#remove_excludes' do
    let(:files) { %w(lib/file.txt exclude.txt file.rb) }
    let(:excludes) { %w(lib exclude.txt) }

    before do
      expect(subject)
        .to receive(:excludes)
        .and_return(excludes)
    end

    it { expect(subject.send(:remove_excludes, files)).to eq ['file.rb'] }
  end

  describe '#excludes' do
    let(:configs) { [rand.to_s] }
    let(:expected) { configs + described_class::DEFAULT_PATHS_TO_EXCLUDE }

    before do
      expect(subject)
        .to receive(:config_excludes)
        .and_return(configs)
    end

    it { expect(subject.send(:excludes)).to eq expected }
  end

  describe '#config_excludes' do
    context 'empty_method_ignored is set' do
      let(:paths) { ["#{rand}.rb", "#{rand}.rb"] }
      let(:config) { double(empty_method_ignored: paths) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config
      end

      it { expect(subject.send(:config_excludes)).to eq paths }
    end

    context 'empty_method_ignored is not set' do
      let(:config) { double(empty_method_ignored: nil) }

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:config)
          .and_return config
      end

      it { expect(subject.send(:config_excludes)).to eq [] }
    end
  end

  describe '#files_from_path' do
    let(:app_root) { PolishGeeks::DevTools.app_root }

    context 'path is a directory' do
      let(:path) { rand.to_s }
      let(:file_in_path) { "#{app_root}/#{rand}" }
      let(:dir_in_path) { "#{app_root}/#{rand}" }

      before do
        expect(File)
          .to receive(:file?)
          .with("#{app_root}/#{path}")
          .and_return(false)

        expect(Dir)
          .to receive(:glob)
          .with("#{app_root}/#{path}")
          .and_return([file_in_path, dir_in_path])

        expect(File)
          .to receive(:file?)
          .with(file_in_path)
          .and_return(true)

        expect(File)
          .to receive(:file?)
          .with(dir_in_path)
          .and_return(false)
      end

      it { expect(subject.send(:files_from_path, path)).to eq [file_in_path] }
    end

    context 'path is a file' do
      let(:path) { rand.to_s }

      before do
        expect(File)
          .to receive(:file?)
          .with("#{app_root}/#{path}")
          .and_return(true)
      end

      it { expect(subject.send(:files_from_path, path)).to eq ["#{app_root}/#{path}"] }
    end
  end

  describe '#sanitize' do
    let(:file) { rand.to_s }
    let(:app_root) { PolishGeeks::DevTools.app_root }
    let(:path) { "#{app_root}/#{file}" }

    it { expect(subject.send(:sanitize, "#{app_root}/#{path}")).to eq file }
  end
end

RSpec.describe PolishGeeks::DevTools::FileParser do
  let(:file) { Tempfile.new('foo') }
  subject { described_class.new(file) }

  describe '#find_empty_methods' do
    context 'empty define_singleton_methods' do
      before do
        file.write("
          define_singleton_method(:a) {}

          define_singleton_method('b') { |_a, _b| }
          define_singleton_method :c do |_a, _b|
            #
            #
          end

          define_singleton_method :d do |_a, _b|
          end
          ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([2, 4, 5, 10]) }
    end

    context 'empty define_methods with comments' do
      before do
        file.write("
          define_method(:a) {} # comment

          define_method('b') { |_a, _b| } # comment
          define_method :c do |_a, _b| # comment
            #
          end
          ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([2, 4, 5]) }
    end

    context 'empty define_methods' do
      before do
        file.write("
          define_method(:a) {}

          define_method('b') { |_a, _b| }
          define_method :c do |_a, _b|
            #
          end
          ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([2, 4, 5]) }
    end

    context 'singleton_methods and methods are defined' do
      before do
        file.write("
          define_singleton_method(:a) { puts rand(5) }

          define_singleton_method(:ab) { |_a, _b| rand(5) }
          define_singleton_method :c do |_a, _b|
            rand(5)
          end
          define_method(:d) { puts rand(5) }

          define_method(:e) { |_a, _b| rand(5) }
          define_method :f do |_a, _b|
            # comment
            # comment
            rand(5)
          end")
        file.read
      end

      it { expect(subject.find_empty_methods).to be_empty }
    end

    context 'empty one line method' do
      before do
        file.write(' def a; end ')
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([1]) }
    end

    context 'empty one line method with comment' do
      before do
        file.write(' def a; end #comment ')
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([1]) }
    end

    context 'empty body method' do
      before do
        file.write(" def a
                     end ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([1]) }
    end

    context 'empty body method with comment' do
      before do
        file.write(" def a # comment
                     end #comment")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([1]) }
    end

    context 'empty method' do
      before do
        file.write(" def a
                      #

                      #
                     end ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([1]) }
    end

    context 'method with comments inside' do
      before do
        file.write(" def a
                      # comment
                      # comment
                      # comment
                      rand(10)
                     end ")
        file.read
      end

      it { expect(subject.find_empty_methods).to be_empty }
    end

    context 'method which defines empty define_method inside' do
      before do
        file.write(" def a
                      define_method(:asd) {}
                     end ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([2]) }
    end

    context 'method which defines empty define_singleton_method inside' do
      before do
        file.write(" def a
                      define_singleton_method(:asd) do
                        # comment
                      end
                     end ")
        file.read
      end

      it { expect(subject.find_empty_methods).to eq([2]) }
    end

    context 'method which defines define_method inside' do
      before do
        file.write(" def a
                      define_method(:asd) { rand(150) } #
                     end ")
        file.read
      end

      it { expect(subject.find_empty_methods).to be_empty }
    end
  end

  describe '#method_has_no_lines?' do
    it { expect(subject.send(:method_has_no_lines?, 2, 4)).to be_falsey }
    it { expect(subject.send(:method_has_no_lines?, 2, 3)).to be_truthy }
  end

  describe '#add_empty_method' do
    it { expect(subject.send(:add_empty_method, 2)).to eq [3] }
  end

  describe '#add_empty_method' do
    it { expect(subject.send(:add_empty_method, 2)).to eq [3] }
  end
end

RSpec.describe PolishGeeks::DevTools::StringRefinements do
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
