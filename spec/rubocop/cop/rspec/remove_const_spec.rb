# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RemoveConst do
  it 'detects the `remove_const` usage' do
    expect_offense(<<~RUBY)
      it 'does something' do
        Object.send(:remove_const, :SomeConstant)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use remove_const in specs. Consider using e.g. `stub_const`.
      end
    RUBY

    expect_offense(<<~RUBY)
      before do
        SomeClass.send(:remove_const, :SomeConstant)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use remove_const in specs. Consider using e.g. `stub_const`.
      end
    RUBY
  end

  it 'detects the `remove_const` usage when using `__send__`' do
    expect_offense(<<~RUBY)
      it 'does something' do
        NiceClass.__send__(:remove_const, :SomeConstant)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use remove_const in specs. Consider using e.g. `stub_const`.
      end
    RUBY
  end
end
