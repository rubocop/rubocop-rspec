# encoding: utf-8

module Rubocop
  module Cop
    # Checks the file and folder naming of the spec file.
    #
    # @example
    #   class/method_spec.rb
    #   class_spec.rb
    class RSpecFileName < Cop
      include TopLevelDescribe

      CLASS_SPEC_MSG = 'Class unit spec should have a path ending with `%s`'
      METHOD_SPEC_MSG = 'Unit spec should have a path matching `%s`'
      METHOD_STRING_MATCHER = /^[\#\.].+/

      def on_top_level_describe(node, args)
        class_or_method = const_name(args.first)
        return unless class_or_method

        path_parts = class_or_method.split('::').map do |part|
          camel_to_underscore(part)
        end

        if !args[1]
          check_class_spec(node, path_parts)
        else
          method_str = args[1].children.first if args[1]
          path_parts << 'class_methods' if method_str.start_with? '.'
          check_method_spec(node, path_parts, method_str)
        end
      end

      private

      def check_class_spec(node, path_parts)
        spec_path = File.join(path_parts) + '_spec.rb'
        return if source_filename.end_with? spec_path

        add_offense(node, :expression, format(CLASS_SPEC_MSG, spec_path))
      end

      def check_method_spec(node, path_parts, method_str)
        matcher_parts = path_parts.dup
        # Strip out symbols; it's not worth enforcing a vocabulary for them.
        matcher_parts << method_str[1..-1].gsub(/\W+/, '*') + '_spec.rb'

        glob_matcher = File.join(matcher_parts)
        return if source_filename =~ regexp_from_glob(glob_matcher)

        add_offense(node, :expression, format(METHOD_SPEC_MSG, glob_matcher))
      end

      def source_filename
        processed_source.buffer.name
      end

      def camel_to_underscore(string)
        string.dup.tap do |result|
          result.gsub!(/([^A-Z])([A-Z]+)/,       '\\1_\\2')
          result.gsub!(/([A-Z]{2,})([A-Z][^A-Z]+)/, '\\1_\\2')
          result.downcase!
        end
      end

      def regexp_from_glob(glob)
        Regexp.new(glob.gsub('.', '\\.').gsub('*', '.*') + '$')
      end
    end
  end
end
