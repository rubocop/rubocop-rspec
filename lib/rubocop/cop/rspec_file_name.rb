# encoding: utf-8

module Rubocop
  module Cop
    # Checks the path of the spec file and enforces that it reflects the
    # described class/module.
    #
    # @example
    #   class/method_spec.rb
    #   class_spec.rb
    class RSpecFileName < Cop
      include TopLevelDescribe

      MESSAGE = 'Spec path should end with `%s`'
      METHOD_STRING_MATCHER = /^[\#\.].+/

      def on_top_level_describe(node, args)
        return unless single_top_level_describe?
        object = const_name(args.first)
        return unless object

        glob_matcher = matcher(object, args[1])
        return if source_filename =~ regexp_from_glob(glob_matcher)

        add_offense(node, :expression, format(MESSAGE, glob_matcher))
      end

      private

      def matcher(object, method)
        method_string = method ? method.children.first.gsub(/\W+/, '') : nil
        path = [File.join(path_parts(object)), method_string].compact.join('_')
        "#{path}*_spec.rb"
      end

      def path_parts(object)
        object.split('::').map do |part|
          camel_to_underscore(part)
        end
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
