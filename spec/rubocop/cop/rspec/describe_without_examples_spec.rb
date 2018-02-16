# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DescribeWithoutExamples do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for an empty `describe`' do
    expect_offense(<<-RUBY.strip_indent)
      describe do
      ^^^^^^^^^^^ Do not use `describe` without examples.
      end
    RUBY
  end

  %w[context feature example_group].each do |keyword|
    it "registers an offense for an empty `#{keyword}`" do
      expect_offense(<<-RUBY.strip_indent)
        #{keyword} do
        #{'^' * (keyword.size + 3)} Do not use `#{keyword}` without examples.
        end
      RUBY
    end
  end

  it 'registers an offense for an `describe` only with `before`' do
    expect_offense(<<-RUBY.strip_indent)
      describe do
      ^^^^^^^^^^^ Do not use `describe` without examples.
        before do
          do_something
        end
      end
    RUBY
  end

  it 'registers an offense for an `describe` with `include_context`' do
    expect_offense(<<-RUBY.strip_indent)
      describe do
      ^^^^^^^^^^^ Do not use `describe` without examples.
        include_context :foobar
      end
    RUBY
  end

  it 'accepts `describe` with an examples' do
    expect_no_offenses(<<-RUBY.strip_indent)
      describe do
        it do
          expect(foo).to eq(something)
        end
      end
    RUBY
  end

  it 'accepts `describe` with an `include_examples`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      describe do
        include_examples :foobar
      end
    RUBY
  end
end
