module RuboCop
  module RSpec
    # Extracts cop descriptions from YARD docstrings
    class DescriptionExtractor
      COP_NAMESPACE = 'RuboCop::Cop::RSpec'.freeze
      COP_FORMAT    = 'RSpec/%s'.freeze

      def initialize(yardocs)
        @yardocs = yardocs
      end

      def to_h
        cop_documentation.each_with_object({}) do |(name, docstring), config|
          config[format(COP_FORMAT, name)] = {
            'Description' => docstring.split("\n\n").first.to_s
          }
        end
      end

      private

      def cop_documentation
        yardocs
          .select(&method(:cop?))
          .map { |doc| [doc.name, doc.docstring] }
      end

      def cop?(doc)
        doc.type.equal?(:class) && doc.to_s.start_with?(COP_NAMESPACE)
      end

      attr_reader :yardocs
    end
  end
end
