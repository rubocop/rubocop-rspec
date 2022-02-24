# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::BeNil do
  it 'registers an offense when using `#be` for `nil` value' do
    expect_offense(<<~RUBY)
      expect(foo).to be(nil)
                     ^^^^^^^ Prefer `be_nil` over `be(nil)`.
    RUBY

    expect_correction(<<~RUBY)
      expect(foo).to be_nil
    RUBY
  end

  it 'does not register an offense when using `#be_nil`' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to be_nil
    RUBY
  end

  it 'does not register an offense when using `#be` with other values' do
    expect_no_offenses(<<~RUBY)
      expect(foo).to be(true)
      expect(foo).to be(false)
      expect(foo).to be(1)
      expect(foo).to be("yes")
      expect(foo).to be(Class.new)
    RUBY
  end
end
