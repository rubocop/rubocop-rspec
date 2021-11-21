# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Favor the use of `file_fixture`.
      #
      # `RSpec` provides the convenience method
      #
      # [source,ruby]
      # ----
      # file_fixture('path/some_file.csv')
      # ----
      #
      # which (by default) is equivalent to
      #
      # [source,ruby]
      # ----
      # Rails.root.join('spec/fixtures/files/path/some_file.csv')
      # ----
      #
      # @example
      #   # bad
      #   "#{Rails.root}/spec/fixtures/path/some_file.csv"
      #   Rails.root.join('spec/fixtures/path/some_file.csv')
      #   Rails.root.join('spec', 'fixtures', 'path', 'some_file.csv')
      #
      #   "#{Rails.root}/spec/fixtures/files/some_file.csv"
      #   Rails.root.join('spec/fixtures/files/some_file.csv')
      #   Rails.root.join('spec', 'fixtures', 'files', 'some_file.csv')
      #
      #   # good
      #   file_fixture('../path/some_file.csv').path
      #   file_fixture('../path/some_file.csv')
      #   file_fixture('../path/some_file.csv')
      #
      #   file_fixture('some_file.csv').path
      #   file_fixture('some_file.csv')
      #   file_fixture('some_file.csv')
      #
      class FileFixture < Base
        extend AutoCorrector

        MSG = 'Use `file_fixture`.'

        RESTRICT_ON_SEND = %i[join root].freeze

        DEFAULT_FILE_FIXTURE_PATTERN = %r{^spec/fixtures/files/}.freeze
        DEFAULT_FIXTURE_PATTERN = %r{^spec/fixtures/}.freeze

        # @!method file_io?(node)
        def_node_matcher :file_io?, <<~PATTERN
          (send
            (const {nil? cbase} :File) {:binread :binwrite :open :read :write} $...)
        PATTERN

        # @!method rails_root_join(node)
        def_node_matcher :rails_root_join, <<~PATTERN
          (send
            (send
              (const {nil? cbase} :Rails) :root) :join (str $_)+)
        PATTERN

        # @!method dstr_rails_root(node)
        def_node_matcher :dstr_rails_root, <<~PATTERN
          (dstr
            (begin
              (send
                (const {nil? cbase} :Rails) :root))
            (str $_))
        PATTERN

        def on_send(node)
          return unless (crime_scene, strings, method = evidence(node))
          return unless (new_path = new_path(strings))

          add_offense(crime_scene) do |corrector|
            replacement = "file_fixture('#{new_path}')"
            replacement += ".#{method}" if method

            corrector.replace(crime_scene, replacement)
          end
        end

        private

        def evidence(node)
          if !file_io?(node.parent) && (string = rails_root_join(node))
            [node, string, nil]
          elsif (string = dstr_rails_root(node.parent.parent))
            [node.parent.parent, string.gsub(%r{^/}, ''), :path]
          end
        end

        def new_path(strings)
          path = File.join(strings)

          if DEFAULT_FILE_FIXTURE_PATTERN.match?(path)
            path.gsub(DEFAULT_FILE_FIXTURE_PATTERN, '')
          elsif DEFAULT_FIXTURE_PATTERN.match?(path)
            path.gsub(DEFAULT_FIXTURE_PATTERN, '../')
          end
        end
      end
    end
  end
end
