require "English"
require "json"
require "redcarpet"

module BlogSnippets
  module Renderers
    class WordpressHTMLRenderer < Redcarpet::Render::HTML
      # http://rubular.com/r/apmHqN4joc
      HEADER_MATCHER = /(?<header><h(?<level>[1-6])[^>]+id="(?<id>[^"]+)".*?>.*?<\/h\k<level>>)/.freeze
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
        remove_new_lines_and_white_space_runs!(document)
        replace_tokens!(document)
        add_header_links!(document)
      end

      private

      def add_header_links!(document)
        document.gsub!(HEADER_MATCHER) do |match|
          match_data = $LAST_MATCH_INFO
          match[0..-6] +
            %Q|<a href="##{match_data[:id]}"><i class="header-link dashicons dashicons-admin-links"></i></a>| +
            "</h#{match_data[:level]}>"
        end
        document
      end

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

      def remove_new_lines_and_white_space_runs!(document)
        # Remove line breaks; HTML should handle breaking lines
        document.gsub!(/\n/, " ")
        # Removing line breaks may have introduced white space runs; zap 'em.
        # http://rubular.com/r/aaVCG1Wlep
        document.gsub!(/(?<=[^\s])\s{2,}/, " ")
        document
      end

      def replace_tokens!(document)
        # Replace tokens with desired characters
        document.gsub!(/#{NEW_LINE_TOKEN}/, "\n")
        document.gsub!(/#{INDENTATION_TOKEN}/, "  ")
        document
      end
    end
  end
end
