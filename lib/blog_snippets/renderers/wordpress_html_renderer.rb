require "redcarpet"
require "json"

module BlogSnippets
  module Renderers
    class WordpressHTMLRenderer < Redcarpet::Render::HTML
      INDENTATION_TOKEN = "__WORDPRESS_HTML_RENDERER_INDENTATION__".freeze
      NEW_LINE_TOKEN = "__WORDPRESS_HTML_RENDERER_NEW_LINE__".freeze

      def initialize(options = nil)
        super(options ||= default_options)
      end

      def block_code(code, language_or_attributes)
        # Replace line breaks with new-line token
        code.gsub!(/\n/, NEW_LINE_TOKEN)
        code.gsub!(/  /, INDENTATION_TOKEN)

        # Extract code tag attributes
        code_attrs = code_attributes(language_or_attributes)
        code_attrs &&= " #{code_attrs}"

        # Can't call super due to C-extension design, so fake it.
        [
          "[code#{code_attrs}]",
          NEW_LINE_TOKEN,
          code,
          "[/code]\n",
        ].join
      end

      def postprocess(document)
        # Remove line breaks; HTML should handle breaking lines
        document.gsub!(/\n/, " ")
        # Removing line breaks may have introduced white space runs; zap 'em.
        # http://rubular.com/r/aaVCG1Wlep
        document.gsub!(/(?<=[^\s])\s{2,}/, " ")
        # Replace tokens with desired characters
        document.gsub!(/#{NEW_LINE_TOKEN}/, "\n")
        document.gsub!(/#{INDENTATION_TOKEN}/, "  ")
        document
      end

      private

      def code_attributes(lang_or_attrs)
        return "language=\"#{lang_or_attrs}\"" unless /[, :]/ === lang_or_attrs

        # Curly braces are omitted for some reason, so restore them.
        attr_json = JSON.parse("{#{lang_or_attrs}}")
        attr_json.map { |key, value| "#{key}=\"#{value}\"" }.join(" ")
      end

      def default_options
        {
          :link_attributes => {
            "target" => "_blank",
          },
          :with_toc_data => true,
        }
      end
    end
  end
end
