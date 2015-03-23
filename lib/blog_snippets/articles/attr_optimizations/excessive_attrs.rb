module BlogSnippets
  module AttrOptimizations
    class ExcessiveAttrs
      def accessor
        @accessor
      end

      def accessor=(value)
        @accessor = value
      end

      def reader
        @reader
      end

      def writer=(value)
        @writer = value
      end
    end
  end
end
