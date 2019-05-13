# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::AlignRightLetBrace do
  subject(:cop) { described_class.new }

  # rubocop:disable RSpec/ExampleLength
  it 'registers offense for unaligned braces' do
    expect_offense(<<-RUBY)
      let(:foo)      { a }
                         ^ Align right let brace
      let(:hi)       { ab }
                          ^ Align right let brace
      let(:blahblah) { abcd }

      let(:thing) { ignore_this }
      let(:other) {
        ignore_this_too
      }

      describe 'blah' do
        let(:blahblah) { a }
                           ^ Align right let brace
        let(:blah)     { bc }
                            ^ Align right let brace
        let(:a)        { abc }
      end
    RUBY

    expect_correction(<<-RUBY)
      let(:foo)      { a    }
      let(:hi)       { ab   }
      let(:blahblah) { abcd }

      let(:thing) { ignore_this }
      let(:other) {
        ignore_this_too
      }

      describe 'blah' do
        let(:blahblah) { a   }
        let(:blah)     { bc  }
        let(:a)        { abc }
      end
    RUBY
  end
  # rubocop:enable RSpec/ExampleLength

  it 'works with empty file' do
    expect_no_offenses('')
  end
end
