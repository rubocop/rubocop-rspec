# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyOutput, :config do
  it 'registers an offense when using `#output` with an empty string' do
    expect_offense(<<~RUBY)
      expect { foo }.to output('').to_stderr
                        ^^^^^^^^^^ Use `not_to` instead of matching on an empty output.
      expect { foo }.to output('').to_stdout
                        ^^^^^^^^^^ Use `not_to` instead of matching on an empty output.
    RUBY

    expect_correction(<<~RUBY)
      expect { foo }.not_to output.to_stderr
      expect { foo }.not_to output.to_stdout
    RUBY
  end

  it 'registers an offense when negatively matching `#output` with ' \
     'an empty string' do
    expect_offense(<<~RUBY)
      expect { foo }.not_to output('').to_stderr
                            ^^^^^^^^^^ Use `to` instead of matching on an empty output.
      expect { foo }.to_not output('').to_stdout
                            ^^^^^^^^^^ Use `to` instead of matching on an empty output.
    RUBY

    expect_correction(<<~RUBY)
      expect { foo }.to output.to_stderr
      expect { foo }.to output.to_stdout
    RUBY
  end

  describe 'compound expectations' do
    it 'does not register an offense when matching empty strings' do
      expect_no_offenses(<<~RUBY)
        expect {
          :noop
        }.to output('').to_stdout.and output('').to_stderr
      RUBY
    end

    it 'does not register an offense when matching non-empty strings' do
      expect_no_offenses(<<~RUBY)
        expect {
          warn "foo"
          puts "bar"
        }.to output("bar\n").to_stdout.and output(/foo/).to_stderr
      RUBY
    end
  end

  it 'does not register an offense when using `#output` with ' \
     'a non-empty string' do
    expect_no_offenses(<<~RUBY)
      expect { foo }.to output('foo').to_stderr
      expect { foo }.not_to output('foo').to_stderr
      expect { foo }.to_not output('foo').to_stderr
    RUBY
  end

  it 'does not register an offense when using `not_to output`' do
    expect_no_offenses(<<~RUBY)
      expect { foo }.not_to output.to_stderr
      expect { foo }.to_not output.to_stderr
    RUBY
  end
end
