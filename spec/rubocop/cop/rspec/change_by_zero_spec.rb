# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ChangeByZero do
  it 'registers an offense when using `change` and argument to `by` is zero' do
    expect_offense(<<~RUBY)
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

    expect_correction(<<~RUBY)
      it do
        expect { foo }.not_to change(Foo, :bar)
        expect { foo }.not_to change(::Foo, :bar)
        expect { foo }.not_to change { Foo.bar }
        expect { foo }.not_to change(Foo, :bar)
      end
    RUBY
  end

  it 'registers an offense when using `a_block_changing` ' \
     'and argument to `by` is zero' do
    expect_offense(<<~RUBY)
      it do
        expect { foo }.to a_block_changing(Foo, :bar).by(0)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to change` over `to a_block_changing.by(0)`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it do
        expect { foo }.not_to change(Foo, :bar)
      end
    RUBY
  end

  it 'registers an offense when using `changing` ' \
     'and argument to `by` is zero' do
    expect_offense(<<~RUBY)
      it do
        expect { foo }.to changing(Foo, :bar).by(0)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_to change` over `to changing.by(0)`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it do
        expect { foo }.not_to change(Foo, :bar)
      end
    RUBY
  end

  context 'when `NegatedMatcher` is not defined (default)' do
    it 'registers an offense when the argument to `by` is zero ' \
       'with compound expectations by `and`' do
      expect_offense(<<~RUBY)
        it do
          expect { foo }.to change(Foo, :bar).by(0).and change(Foo, :baz).by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                        ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          expect { foo }.to change { Foo.bar }.by(0).and change { Foo.baz }.by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                         ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when the argument to `by` is zero ' \
       'with compound expectations by `&`' do
      expect_offense(<<~RUBY)
        it do
          expect { foo }.to change(Foo, :bar).by(0) & change(Foo, :baz).by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          expect { foo }.to change { Foo.bar }.by(0) & change { Foo.baz }.by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                       ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when the argument to `by` is zero ' \
       'with compound expectations by `or`' do
      expect_offense(<<~RUBY)
        it do
          expect { foo }.to change(Foo, :bar).by(0).or change(Foo, :baz).by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                       ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          expect { foo }.to change { Foo.bar }.by(0).or change { Foo.baz }.by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                        ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when the argument to `by` is zero ' \
       'with compound expectations by `|`' do
      expect_offense(<<~RUBY)
        it do
          expect { foo }.to change(Foo, :bar).by(0) | change(Foo, :baz).by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
          expect { foo }.to change { Foo.bar }.by(0) | change { Foo.baz }.by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
                                                       ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer negated matchers with compound expectations over `change.by(0)`.
        end
      RUBY

      expect_no_corrections
    end

    context 'when with a line break' do
      it 'registers an offense when the argument to `by` is zero ' \
         'with compound expectations by `and`' do
        expect_offense(<<~RUBY)
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
          end
        RUBY

        expect_no_corrections
      end

      it 'registers an offense when the argument to `by` is zero ' \
         'with compound expectations by `&`' do
        expect_offense(<<~RUBY)
          it do
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
          end
        RUBY

        expect_no_corrections
      end

      it 'registers an offense when the argument to `by` is zero ' \
         'with compound expectations by `or`' do
        expect_offense(<<~RUBY)
          it do
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
          end
        RUBY

        expect_no_corrections
      end

      it 'registers an offense when the argument to `by` is zero ' \
         'with compound expectations by `|`' do
        expect_offense(<<~RUBY)
          it do
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
    end
  end

  context "with `NegatedMatcher: 'not_change'`" do
    let(:cop_config) { { 'NegatedMatcher' => 'not_change' } }

    it 'registers an offense and autocorrect when ' \
       'the argument to `by` is zero with compound expectations' do
      expect_offense(<<~RUBY)
        it do
          expect { foo }.to change(Foo, :bar).by(0).and change(Foo, :baz).by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
                                                        ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
          expect { foo }.to change { Foo.bar }.by(0).and change { Foo.baz }.by(0)
                            ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
                                                         ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
        end
      RUBY

      expect_correction(<<~RUBY)
        it do
          expect { foo }.to not_change(Foo, :bar).and not_change(Foo, :baz)
          expect { foo }.to not_change { Foo.bar }.and not_change { Foo.baz }
        end
      RUBY
    end

    it 'registers an offense and autocorrect when ' \
       'the argument to `by` is zero with compound expectations ' \
       'with line break' do
      expect_offense(<<~RUBY)
        it do
          expect { foo }
            .to change(Foo, :bar).by(0)
                ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
            .and change(Foo, :baz).by(0)
                 ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
          expect { foo }
            .to change { Foo.bar }.by(0)
                ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
            .and change { Foo.baz }.by(0)
                 ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `not_change` with compound expectations over `change.by(0)`.
        end
      RUBY

      expect_correction(<<~RUBY)
        it do
          expect { foo }
            .to not_change(Foo, :bar)
            .and not_change(Foo, :baz)
          expect { foo }
            .to not_change { Foo.bar }
            .and not_change { Foo.baz }
        end
      RUBY
    end
  end

  it 'does not register an offense when the argument to `by` is not zero' do
    expect_no_offenses(<<~RUBY)
      it do
        expect { foo }.to change(Foo, :bar).by(1)
        expect { foo }.to change { Foo.bar }.by(1)
      end
    RUBY
  end
end
