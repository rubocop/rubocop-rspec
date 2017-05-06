RSpec.describe ExpectOffense do
  let(:cop) do
    stub_const('RuboCop::Cop::Test', Module.new)

    module RuboCop
      module Cop
        module Test
          class OffendedBySend < RuboCop::Cop::Cop
            MSG = 'This is offensive'.freeze

            def on_send(node)
              add_offense(node, :expression)
            end
          end
        end
      end
    end

    RuboCop::Cop::Test::OffendedBySend.new
  end

  it 'rejects offenses which annotate the wrong parts of the source' do
    expect do
      expect_offense(<<-RUBY)
        a=b
        ^ This is offensive
      RUBY
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'accepts multiple annotations per line' do
    expect_offense(<<-RUBY)
    a = b(c)
        ^^^^ This is offensive
          ^ This is offensive
    a
    d
    ^ This is offensive
    RUBY
  end

  it 'allows lines with multiple annotations to have any order' do
    expect_offense(<<-RUBY)
    a = b(c)
          ^ This is offensive
        ^^^^ This is offensive
    a
    d
    ^ This is offensive
    RUBY
  end

  # rubocop:disable RSpec/ExampleLength
  it 'reconstructs annotated source to have deterministic ordering' do
    source1 = <<-SOURCE
    foo
    ^ First column
    ^^ First column longer highlight
    ^^ Same column different message
    line_without_annotations
    another_line
    ^^^^^^^^^^^^ Separate annotation
    SOURCE

    source2 = <<-SOURCE
    foo
    ^^ First column longer highlight
    ^^ Same column different message
    ^ First column
    line_without_annotations
    another_line
    ^^^^^^^^^^^^ Separate annotation
    SOURCE

    standardized1 = described_class::AnnotatedSource.parse(source1).to_s
    standardized2 = described_class::AnnotatedSource.parse(source2).to_s

    expect(standardized2).to eql(standardized1).and eql(source1)
  end
  # rubocop:enable RSpec/ExampleLength
end
