# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::Output do
  it 'registers an offense for using `p` method without a receiver' do
    expect_offense(<<~RUBY)
      p "edmond dantes"
      ^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense for using `puts` method without a receiver' do
    expect_offense(<<~RUBY)
      puts "sinbad"
      ^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense for using `print` method without a receiver' do
    expect_offense(<<~RUBY)
      print "abbe busoni"
      ^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense for using `pp` method without a receiver' do
    expect_offense(<<~RUBY)
      pp "monte cristo"
      ^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense with `$stdout.write`' do
    expect_offense(<<~RUBY)
      $stdout.write "lord wilmore"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense with `$stderr.syswrite`' do
    expect_offense(<<~RUBY)
      $stderr.syswrite "faria"
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense with `STDOUT.write`' do
    expect_offense(<<~RUBY)
      STDOUT.write "bertuccio"
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense with `::STDOUT.write`' do
    expect_offense(<<~RUBY)
      ::STDOUT.write "bertuccio"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense with `STDERR.write`' do
    expect_offense(<<~RUBY)
      STDERR.write "bertuccio"
      ^^^^^^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'registers an offense with `::STDERR.write`' do
    expect_offense(<<~RUBY)
      ::STDERR.write "bertuccio"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'does not record an offense for methods with a receiver' do
    expect_no_offenses(<<~RUBY)
      obj.print
      something.p
      nothing.pp
    RUBY
  end

  it 'registers an offense for methods without arguments' do
    expect_offense(<<~RUBY)
      print
      ^^^^^ Do not write to stdout in specs.
      pp
      ^^ Do not write to stdout in specs.
      puts
      ^^^^ Do not write to stdout in specs.
      $stdout.write
      ^^^^^^^^^^^^^ Do not write to stdout in specs.
      STDERR.write
      ^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)





    RUBY
  end

  it 'registers an offense when `p` method with positional argument' do
    expect_offense(<<~RUBY)
      p(do_something)
      ^^^^^^^^^^^^^^^ Do not write to stdout in specs.
    RUBY

    expect_correction(<<~RUBY)

    RUBY
  end

  it 'does not register an offense when a method is called ' \
     'to a local variable with the same name as a print method' do
    expect_no_offenses(<<~RUBY)
      p.do_something
    RUBY
  end

  it 'does not register an offense when `p` method with keyword argument' do
    expect_no_offenses(<<~RUBY)
      p(class: 'this `p` method is a DSL')
    RUBY
  end

  it 'does not register an offense when `p` method with symbol proc' do
    expect_no_offenses(<<~RUBY)
      p(&:this_p_method_is_a_dsl)
    RUBY
  end

  it 'does not register an offense when the `p` method is called ' \
     'with block argument' do
    expect_no_offenses(<<~RUBY)
      # phlex-rails gem.
      div do
        p { 'Some text' }
      end
    RUBY
  end

  it 'does not register an offense when io method is called ' \
     'with block argument' do
    expect_no_offenses(<<~RUBY)
      obj.write { do_somethig }
    RUBY
  end

  it 'does not register an offense when io method is called ' \
     'with numbered block argument' do
    expect_no_offenses(<<~RUBY)
      obj.write { do_something(_1) }
    RUBY
  end

  it 'does not register an offense when io method is called ' \
     'with `it` parameter', :ruby34, unsupported_on: :parser do
    expect_no_offenses(<<~RUBY)
      obj.write { do_something(it) }
    RUBY
  end

  it 'does not register an offense when a method is safe navigation called ' \
     'to a local variable with the same name as a print method' do
    expect_no_offenses(<<~RUBY)
      p&.do_something
    RUBY
  end

  it 'does not record an offense for comments' do
    expect_no_offenses(<<~RUBY)
      # print "test"
      # p
      # $stdout.write
      # STDERR.binwrite
    RUBY
  end
end
