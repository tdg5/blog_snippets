module BlogSnippets
  class MarkdownToHTMLTransformer

    DEFAULT_MARKDOWN_EXTENSIONS = {
      :autolink => true,
      :disable_indented_code_blocks => true,
      :fenced_code_blocks => true,
      :footnotes => true,
      :no_intra_emphasis => true,
      :space_after_headers => true,
      :strikethrough => true,
      :tables => true,
      :underline => true,
    }

    attr_reader :markdown_extensions, :renderer

    def self.default_markdown_extensions
      const_get(:DEFAULT_MARKDOWN_EXTENSIONS).dup
    end

    def initialize(options = {})
      raise ArgumentError, ":renderer is required!" unless options[:renderer]
      raise ArgumentError, ":parser_class is required!" unless options[:parser_class]

      @renderer = options[:renderer]
      @parser_class = options[:parser_class]
      @markdown_extensions = options[:markdown_extensions] || default_markdown_extensions
    end

    def parser
      @parser ||= parser_class.new(renderer, @markdown_extensions)
    end

    def transform(markdown)
      parser.render(markdown)
    end

    private

    attr_reader :parser_class

    def default_markdown_extensions
      self.class.default_markdown_extensions
    end
  end
end
