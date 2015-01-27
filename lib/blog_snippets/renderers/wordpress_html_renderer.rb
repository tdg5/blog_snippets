require 'redcarpet'
require 'pry'

module BlogSnippets
  module Renderers
    class WordpressHTMLRenderer < Redcarpet::Render::HTML
      INDENTATION_TOKEN = '__WORDPRESS_HTML_RENDERER_INDENTATION__'
      NEW_LINE_TOKEN = '__WORDPRESS_HTML_RENDERER_NEW_LINE__'

      def initialize(options = nil)
        options ||= default_options
        super(options)
      end

      def block_code(code, language)
        # Replace line breaks with new-line token
        code.gsub!(/\n/, NEW_LINE_TOKEN)
        code.gsub!(/  /, INDENTATION_TOKEN)
        # Can't call super due to C-extension design, so fake it.
        "[code language=\"#{language}\"]#{NEW_LINE_TOKEN}#{code}[/code]\n"
      end

      def postprocess(document)
        # Remove line breaks; HTML should handle breaking lines
        document.gsub!(/\n/, ' ')
        # Removing line breaks may have introduced white space runs; zap 'em.
        # http://rubular.com/r/aaVCG1Wlep
        document.gsub!(/(?<=[^\s])\s{2,}/, ' ')
        # Replace tokens with desired characters
        document.gsub!(/#{NEW_LINE_TOKEN}/, "\n")
        document.gsub!(/#{INDENTATION_TOKEN}/, '  ')
        document
      end

      private

      def default_options
        {
          :link_attributes => {
            'target' => '_blank',
          },
          :with_toc_data => true,
        }
      end
    end
  end
end
