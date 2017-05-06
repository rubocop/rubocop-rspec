# frozen_string_literal: true

module ExpectOffense
  DEFAULT_FILENAME = 'example_spec.rb'.freeze

  # rubocop:disable Metrics/AbcSize
  def expect_offense(source, filename: DEFAULT_FILENAME)
    expectation = Expectation.new(source)
    inspect_source(cop, expectation.source, filename)
    offenses = cop.offenses.map(&method(:to_assertion)).sort

    if expectation.assertions.empty?
      raise 'Use expect_no_offenses to assert no violations'
    end

    expect(offenses).to eq(expectation.assertions.sort)
  end

  def expect_no_offenses(source, filename: DEFAULT_FILENAME)
    inspect_source(cop, source, filename)

    expect(cop.offenses.empty?).to be(true)
  end

  private

  def to_assertion(offense)
    highlight = offense.highlighted_area

    Expectation::Assertion.new(
      message:      offense.message,
      line_number:  offense.location.first_line,
      column_range: highlight.begin_pos...highlight.end_pos
    )
  end

  class Expectation
    def initialize(string)
      @string = string
    end

    VIOLATION_LINE_PATTERN = /\A *\^/

    VIOLATION = :violation
    SOURCE    = :line

    def source
      source_map.to_s
    end

    def assertions
      source_map.assertions
    end

    private

    attr_reader :string

    def source_map
      @source_map ||=
        tokens.reduce(Source::BLANK) do |source, (type, tokens)|
          tokens.reduce(source, :"add_#{type}")
        end
    end

    def tokens
      string.each_line.chunk do |line|
        next SOURCE unless line =~ VIOLATION_LINE_PATTERN

        VIOLATION
      end
    end

    class Source
      def initialize(lines)
        @lines = lines
      end

      BLANK = new([].freeze)

      def add_line(line)
        self.class.new(lines + [Line.new(text: line, number: lines.size + 1)])
      end

      def add_violation(violation)
        self.class.new([*lines[0...-1], lines.last.add_violation(violation)])
      end

      def to_s
        lines.map(&:text).join
      end

      def assertions
        lines.flat_map(&:assertions)
      end

      private

      attr_reader :lines

      class Line
        DEFAULTS = { violations: [] }.freeze

        attr_reader :text, :number, :violations

        def initialize(options)
          options = DEFAULTS.merge(options)

          @text       = options.fetch(:text)
          @number     = options.fetch(:number)
          @violations = options.fetch(:violations)
        end

        def add_violation(violation)
          self.class.new(
            text:       text,
            number:     number,
            violations: violations + [violation]
          )
        end

        def assertions
          violations.map do |violation|
            Assertion.parse(
              text:        violation,
              line_number: number
            )
          end
        end
      end
    end

    class Assertion
      include Comparable

      attr_reader :message, :column_range, :line_number

      def initialize(options)
        @message      = options.fetch(:message)
        @column_range = options.fetch(:column_range)
        @line_number  = options.fetch(:line_number)
      end

      def self.parse(text:, line_number:)
        parser = Parser.new(text)

        new(
          message:      parser.message,
          column_range: parser.column_range,
          line_number:  line_number
        )
      end

      def <=>(other)
        to_a <=> other.to_a
      end

      def to_a
        [line_number, column_range.first, column_range.last, message]
      end

      class Parser
        def initialize(text)
          @text = text
        end

        COLUMN_PATTERN = /^ *(?<carets>\^\^*) (?<message>.+)$/

        def column_range
          Range.new(*match.offset(:carets), true)
        end

        def message
          match[:message]
        end

        private

        attr_reader :text

        def match
          @match ||= text.match(COLUMN_PATTERN)
        end
      end

      private_constant(*constants(false))
    end
  end
end
