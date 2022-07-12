# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ChangeByZero do
  it 'registers an offense when the argument to `by` is zero' do
    expect_offense(<<-RUBY)
      it do
        expect { foo }.to change(Foo, :bar).by(0)
                          ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to change` over `to change.by(0)`.
        expect { foo }.to change(::Foo, :bar).by(0)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to change` over `to change.by(0)`.
        expect { foo }.to change { Foo.bar }.by(0)
                          ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to change` over `to change.by(0)`.
        expect { foo }.to change(Foo, :bar).by 0
                          ^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to change` over `to change.by(0)`.
      end
    RUBY

    expect_correction(<<-RUBY)
      it do
        expect { foo }.not_to change(Foo, :bar)
        expect { foo }.not_to change(::Foo, :bar)
        expect { foo }.not_to change { Foo.bar }
        expect { foo }.not_to change(Foo, :bar)
      end
    RUBY
  end

  it 'registers an offense when the argument to `by` is zero ' \
    'with compound expectations' do
    expect_offense(<<-RUBY)
      it do
        expect { foo }
          .to change(Foo, :bar).by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          .and change(Foo, :baz).by(0)
               ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change { Foo.bar }.by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          .and change { Foo.baz }.by(0)
               ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change(Foo, :bar).by(0) &
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
              change(Foo, :baz).by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change { Foo.bar }.by(0) &
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
              change { Foo.baz }.by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change(Foo, :bar).by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          .or change(Foo, :baz).by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change { Foo.bar }.by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          .or change { Foo.baz }.by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change(Foo, :bar).by(0) |
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
              change(Foo, :baz).by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        expect { foo }
          .to change { Foo.bar }.by(0) |
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
              change { Foo.baz }.by(0)
              ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
      end
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense when the argument to `by` is not zero' do
    expect_no_offenses(<<-RUBY)
      it do
        expect { foo }.to change(Foo, :bar).by(1)
        expect { foo }.to change { Foo.bar }.by(1)
      end
    RUBY
  end
end
