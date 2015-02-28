module BlogSnippets
  class MarkdownToHTMLTransformer

    def initialize(options = {})
      @renderer = options[:renderer]
      @markdown_extensions = options[:markdown_extensions] || default_markdown_extensions
    end

    def transform(markdown)
      parser.render(markdown)
    end

    private

    attr_reader :renderer

    def default_markdown_extensions
      {
        :autolink => true,
        :disable_indented_code_blocks => true,
        :fenced_code_blocks => true,
        :footnotes => true,
        :no_intra_emphasis => true,
        :space_after_headers => true,
        :tables => true,
      }
    end

    def parser
      @parser ||= Redcarpet::Markdown.new(renderer, @markdown_extensions)
    end
  end
end
