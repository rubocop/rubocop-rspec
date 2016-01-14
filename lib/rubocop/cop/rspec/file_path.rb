# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks the path of the spec file and enforces that it reflects the
      # described class/module and its optionally called out method.
      #
      # With the configuration option `CustomTransform` modules or clases can be
      # specified that should not as usual be transformed from CamelCase to
      # snake_case (e.g. 'RuboCop' => 'rubocop' ).
      #
      # @example
      #   my_class/method_spec.rb  # describe MyClass, '#method'
      #   my_class_method_spec.rb  # describe MyClass, '#method'
      #   my_class_spec.rb         # describe MyClass
      class FilePath < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MESSAGE = 'Spec path should end with `%s`'
        METHOD_STRING_MATCHER = /^[\#\.].+/

        def on_top_level_describe(node, args)
          return unless single_top_level_describe?
          object = args.first.const_name
          return unless object

          path_matcher = matcher(object, args[1])
          return if source_filename =~ regexp_from_glob(path_matcher)

          add_offense(node, :expression, format(MESSAGE, path_matcher))
        end

        private

        def matcher(object, method)
          path = File.join(parts(object))
          if method && method.type == :str
            path += '*' + method.children.first.gsub(/\W+/, '')
          end

          "#{path}*_spec.rb"
        end

        def parts(object)
          object.split('::').map do |p|
            custom_transform[p] || camel_to_underscore(p)
          end
        end

        def source_filename
          processed_source.buffer.name
        end

        def camel_to_underscore(string)
          string.dup.tap do |result|
            result.gsub!(/([^A-Z])([A-Z]+)/, '\\1_\\2')
            result.gsub!(/([A-Z])([A-Z][^A-Z]+)/, '\\1_\\2')
            result.downcase!
          end
        end

        def regexp_from_glob(glob)
          Regexp.new(glob.gsub('.', '\\.').gsub('*', '.*') + '$')
        end

        def custom_transform
          cop_config['CustomTransform'] || []
        end
      end
    end
  end
end
