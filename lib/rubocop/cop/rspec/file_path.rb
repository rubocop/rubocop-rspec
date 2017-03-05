# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that spec file paths are consistent with the test subject.
      #
      # Checks the path of the spec file and enforces that it reflects the
      # described class/module and its optionally called out method.
      #
      # With the configuration option `IgnoreMethods` the called out method will
      # be ignored when determining the enforced path.
      #
      # With the configuration option `CustomTransform` modules or classes can
      # be specified that should not as usual be transformed from CamelCase to
      # snake_case (e.g. 'RuboCop' => 'rubocop' ).
      #
      # @example
      #   # bad
      #   whatever_spec.rb         # describe MyClass
      #
      #   # bad
      #   my_class_spec.rb         # describe MyClass, '#method'
      #
      #   # good
      #   my_class_spec.rb         # describe MyClass
      #
      #   # good
      #   my_class_method_spec.rb  # describe MyClass, '#method'
      #
      #   # good
      #   my_class/method_spec.rb  # describe MyClass, '#method'
      #
      # @example when configuration is `IgnoreMethods: true`
      #   # bad
      #   whatever_spec.rb         # describe MyClass
      #
      #   # good
      #   my_class_spec.rb         # describe MyClass
      #
      #   # good
      #   my_class_spec.rb         # describe MyClass, '#method'
      #
      class FilePath < Cop
        include RuboCop::RSpec::TopLevelDescribe

        MSG          = 'Spec path should end with `%s`.'.freeze
        ROUTING_PAIR = s(:pair, s(:sym, :type), s(:sym, :routing))

        def on_top_level_describe(node, args)
          return if routing_spec?(args)

          return unless single_top_level_describe?
          object = args.first.const_name
          return unless object

          path_matcher = matcher(object, args.at(1))
          return if source_filename =~ regexp_from_glob(path_matcher)

          add_offense(node, :expression, format(MSG, path_matcher))
        end

        private

        def relevant_rubocop_rspec_file?(_)
          true
        end

        def routing_spec?(args)
          args.any? do |arg|
            arg.children.include?(ROUTING_PAIR)
          end
        end

        def matcher(object, method)
          path = File.join(parts(object))
          if method && method.type.equal?(:str) && !ignore_methods?
            path += '*' + method.str_content.gsub(/\W+/, '')
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
          string
            .gsub(/([^A-Z])([A-Z]+)/, '\1_\2')
            .gsub(/([A-Z])([A-Z][^A-Z\d]+)/, '\1_\2')
            .downcase
        end

        def regexp_from_glob(glob)
          Regexp.new(glob.sub('.', '\\.').gsub('*', '.*') + '$')
        end

        def ignore_methods?
          cop_config['IgnoreMethods']
        end

        def custom_transform
          cop_config['CustomTransform'] || {}
        end
      end
    end
  end
end
