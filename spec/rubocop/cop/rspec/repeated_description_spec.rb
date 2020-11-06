# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedDescription do
  it 'registers an offense for repeated descriptions' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
        it "does x" do
        ^^^^^^^^^^^ Don't repeat descriptions within an example group.
        end

        it "does x" do
        ^^^^^^^^^^^ Don't repeat descriptions within an example group.
        end
      end
    RUBY
  end

  it 'registers offense for repeated descriptions separated by a context' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
        it "does x" do
        ^^^^^^^^^^^ Don't repeat descriptions within an example group.
        end

        context 'during some use case' do
          it "does x" do
            # this should be fine
          end
        end

        it "does x" do
        ^^^^^^^^^^^ Don't repeat descriptions within an example group.
        end
      end
    RUBY
  end

  it 'ignores descriptions repeated in a shared context' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it "does x" do
        end

        shared_context 'shared behavior' do
          it "does x" do
          end
        end
      end
    RUBY
  end

  it 'ignores repeated descriptions in a nested context' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it "does x" do
        end

        context 'in a certain use case' do
          it "does x" do
          end
        end
      end
    RUBY
  end

  it 'does not flag tests which do not contain description strings' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it { foo }
        it { bar }
      end
    RUBY
  end

  it 'does not flag examples if metadata is different' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it 'do something' do
          # ...
        end

        it 'do something', :flag do
          # ...
        end
      end
    RUBY
  end

  it 'does not flag examples with same metadata and different description' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it 'do something', :flag do
          # ...
        end

        it 'do another thing', :flag do
          # ...
        end
      end
    RUBY
  end

  it 'registers offense for repeated description and metadata' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
        it 'do something', :flag do
        ^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          # ...
        end

        it 'do something', :flag do
        ^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          # ...
        end
      end
    RUBY
  end

  it 'does not flag descriptions with different interpolated variables' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it "does \#{x}" do
        end

        it "does \#{y}" do
        end
      end
    RUBY
  end

  it 'registers offense for repeated description in same iterator' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
        %i[foo bar].each do |type|
          it "does a thing \#{type}" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          end

          it "does a thing \#{type}" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          end
        end
      end
    RUBY
  end

  it 'registers offense for repeated description in different iterators' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
        %i[foo bar].each do |type|
          it "does a thing \#{type}" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          end
        end

        %i[baz qux].each do |type|
          it "does a thing \#{type}" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          end
        end
      end
    RUBY
  end

  it 'does not flag different descriptions in different iterators' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        %i[foo bar].each do |type|
          it "does a thing \#{type}" do
          end
        end

        %i[baz qux].each do |type|
          it "does another thing \#{type}" do
          end
        end
      end
    RUBY
  end

  it 'registers offense if same method used in docstring' do
    expect_offense(<<-RUBY)
      describe 'doing x' do
        it(description) do
        ^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          # ...
        end

        it(description) do
        ^^^^^^^^^^^^^^^ Don't repeat descriptions within an example group.
          # ...
        end
      end
    RUBY
  end

  it 'does not flag different methods used as docstring' do
    expect_no_offenses(<<-RUBY)
      describe 'doing x' do
        it(description) do
          # ...
        end

        it(title) do
          # ...
        end
      end
    RUBY
  end
end
