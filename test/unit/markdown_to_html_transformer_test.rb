require "test_helper"
require "blog_snippets/markdown_to_html_transformer"

class MarkdownToHTMLTransformerTest < BlogSnippets::TestCase
  Subject = BlogSnippets::MarkdownToHTMLTransformer

  subject { Subject }

  context "::default_markdown_extensions" do
    should "return expected defaults" do
      expected = {
        :autolink => true,
        :disable_indented_code_blocks => true,
        :fenced_code_blocks => true,
        :footnotes => true,
        :no_intra_emphasis => true,
        :space_after_headers => true,
        :tables => true,
      }
      assert_equal expected, subject.default_markdown_extensions
    end

    should "return a new Hash instance each call" do
      first_defaults = subject.default_markdown_extensions
      second_defaults = subject.default_markdown_extensions
      refute_equal first_defaults.object_id, second_defaults.object_id
    end
  end

  context "#initialize" do
    [:parser_class, :renderer].each do |required_opt|
      should "raise unless #{required_opt} option is given" do
        assert_raises(ArgumentError) do
          opts = default_initialization_options
          opts.delete(required_opt)
          subject.new(opts)
        end
      end
    end

    should "assign given :renderer to #renderer" do
      instance = subject.new(default_initialization_options)
      assert_equal renderer, instance.renderer
    end

    should "take a Hash of Markdown extensions" do
      exts = { :tables => true }
      opts = default_initialization_options.merge(:markdown_extensions => exts)
      instance = subject.new(opts)
      assert_equal exts, instance.markdown_extensions
    end

    should "use default Markdown extensions if none given" do
      opts = default_initialization_options
      opts.delete(:markdown_extensions)
      instance = subject.new(opts)
      assert_equal subject.default_markdown_extensions, instance.markdown_extensions
    end

    should "assign :markdown_extensions to #markdown_extensions" do
      exts = { :tables => true }
      opts = default_initialization_options.merge(:markdown_extensions => exts)
      instance = subject.new(opts)
      assert_equal exts, instance.markdown_extensions
    end
  end

  context "instance_methods" do
    subject { Subject.new(default_initialization_options) }

    context "#parser" do
      should "initialize an instance of parser_class with renderer and markdown extensions" do
        parser_class.expects(:new).with(subject.renderer, subject.markdown_extensions)
        subject.parser
      end
    end

    context "#transform" do
      should "invoke parser#render with given markdown" do
        markdown = "# Hello World!"
        subject.expects(:parser).returns(mck = mock)
        mck.expects(:render).with(markdown)
        subject.transform(markdown)
      end
    end
  end

  def default_initialization_options
    {
      :parser_class => parser_class,
      :renderer => renderer,
    }
  end

  def parser_class
    @parser_class ||= mock
  end

  def renderer
    @renderer ||= mock
  end
end
