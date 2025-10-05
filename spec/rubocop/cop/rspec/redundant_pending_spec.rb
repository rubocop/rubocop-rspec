# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RedundantPending do
  it 'registers an offense for pending inside xit' do
    expect_offense(<<~RUBY)
      xit 'does something' do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for skip inside xit' do
    expect_offense(<<~RUBY)
      xit 'does something' do
        skip 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `skip` inside already skipped example. Remove `skip` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending inside xspecify' do
    expect_offense(<<~RUBY)
      xspecify do
        pending 'Need to upgrade to the latest HTTP gem version'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(pinger.call).to eq(204)
      end
    RUBY
  end

  it 'registers an offense for pending inside xexample' do
    expect_offense(<<~RUBY)
      xexample 'does something' do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending inside example with :skip metadata' do
    expect_offense(<<~RUBY)
      it 'does something', :skip do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for skip inside example with :skip metadata' do
    expect_offense(<<~RUBY)
      it 'does something', :skip do
        skip 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `skip` inside already skipped example. Remove `skip` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending inside example with :pending metadata' do
    expect_offense(<<~RUBY)
      it 'does something', :pending do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending inside example with ' \
     'skip: true metadata' do
    expect_offense(<<~RUBY)
      it 'does something', skip: true do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for skip inside example with ' \
     'skip: "reason" metadata' do
    expect_offense(<<~RUBY)
      it 'does something', skip: 'not ready' do
        skip 'duplicate reason'
        ^^^^^^^^^^^^^^^^^^^^^^^ Redundant `skip` inside already skipped example. Remove `skip` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending inside example with ' \
     'pending: true metadata' do
    expect_offense(<<~RUBY)
      it 'does something', pending: true do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'does not register an offense for pending inside regular it' do
    expect_no_offenses(<<~RUBY)
      it 'does something' do
        pending 'not yet implemented'
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'does not register an offense for skip inside regular it' do
    expect_no_offenses(<<~RUBY)
      it 'does something' do
        skip 'not yet implemented'
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'does not register an offense for pending inside regular specify' do
    expect_no_offenses(<<~RUBY)
      specify do
        pending 'not yet implemented'
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'does not register an offense when skip/pending is not ' \
     'the first statement' do
    expect_no_offenses(<<~RUBY)
      xit 'does something' do
        setup_something
        pending 'not yet implemented'
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'does not register an offense for example with skip: false metadata' do
    expect_no_offenses(<<~RUBY)
      it 'does something', skip: false do
        pending 'not yet implemented'
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'does not register an offense for example with pending: false metadata' do
    expect_no_offenses(<<~RUBY)
      it 'does something', pending: false do
        skip 'not yet implemented'
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending in numblock with xit' do
    expect_offense(<<~RUBY)
      xit do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(_1).to be_truthy
      end
    RUBY
  end

  it 'registers an offense when example body has multiple statements' do
    expect_offense(<<~RUBY)
      xit 'does something' do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
        expect(something).to be_truthy
        expect(another).to be_falsey
      end
    RUBY
  end

  it 'does not register an offense for xit without body' do
    expect_no_offenses(<<~RUBY)
      xit 'does something'
    RUBY
  end

  it 'does not register an offense for xit with empty body' do
    expect_no_offenses(<<~RUBY)
      xit 'does something' do
      end
    RUBY
  end

  it 'registers an offense when body is a single pending statement' do
    expect_offense(<<~RUBY)
      xit 'does something' do
        pending 'not yet implemented'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
      end
    RUBY
  end

  it 'registers an offense when body is a single skip statement' do
    expect_offense(<<~RUBY)
      xspecify do
        skip 'not ready yet'
        ^^^^^^^^^^^^^^^^^^^^ Redundant `skip` inside already skipped example. Remove `skip` or use regular example method.
      end
    RUBY
  end

  it 'does not register an offense when body is a single non-skip/pending ' \
     'statement' do
    expect_no_offenses(<<~RUBY)
      xit 'does something' do
        expect(something).to be_truthy
      end
    RUBY
  end

  it 'registers an offense for pending in one-liner example body' do
    expect_offense(<<~RUBY)
      xit('does something') { pending 'not ready' }
                              ^^^^^^^^^^^^^^^^^^^ Redundant `pending` inside already skipped example. Remove `pending` or use regular example method.
    RUBY
  end
end
