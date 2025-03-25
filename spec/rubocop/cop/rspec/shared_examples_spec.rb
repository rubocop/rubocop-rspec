# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SharedExamples do
  context 'when using default (string) enforced style' do
    it 'registers an offense when using symbolic title' do
      expect_offense(<<~RUBY)
        it_behaves_like :foo_bar_baz
                        ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
        it_should_behave_like :foo_bar_baz
                              ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
        shared_examples :foo_bar_baz
                        ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
        shared_examples_for :foo_bar_baz
                            ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
        include_examples :foo_bar_baz
                         ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
        include_examples :foo_bar_baz, 'foo', 'bar'
                         ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.

        shared_examples :foo_bar_baz, 'foo', 'bar', :foo_bar, 5 do |param|
                        ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
          # ...
        end

        RSpec.shared_examples :foo_bar_baz
                              ^^^^^^^^^^^^ Prefer 'foo bar baz' over `:foo_bar_baz` to titleize shared examples.
      RUBY

      expect_correction(<<~RUBY)
        it_behaves_like 'foo bar baz'
        it_should_behave_like 'foo bar baz'
        shared_examples 'foo bar baz'
        shared_examples_for 'foo bar baz'
        include_examples 'foo bar baz'
        include_examples 'foo bar baz', 'foo', 'bar'

        shared_examples 'foo bar baz', 'foo', 'bar', :foo_bar, 5 do |param|
          # ...
        end

        RSpec.shared_examples 'foo bar baz'
      RUBY
    end

    it 'does not register an offense when using string title' do
      expect_no_offenses(<<~RUBY)
        it_behaves_like 'foo bar baz'
        it_should_behave_like 'foo bar baz'
        shared_examples 'foo bar baz'
        shared_examples_for 'foo bar baz'
        include_examples 'foo bar baz'
        include_examples 'foo bar baz', 'foo', 'bar'

        shared_examples 'foo bar baz', 'foo', 'bar' do |param|
          # ...
        end
      RUBY
    end

    it 'does not register an offense when using Module/Class title' do
      expect_no_offenses(<<~RUBY)
        it_behaves_like FooBarBaz
        it_should_behave_like FooBarBaz
        shared_examples FooBarBaz
        shared_examples_for FooBarBaz
        include_examples FooBarBaz
        include_examples FooBarBaz, 'foo', 'bar'

        shared_examples FooBarBaz, 'foo', 'bar' do |param|
          # ...
        end
      RUBY
    end
  end

  context 'when using symbol enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symbol' } }

    it 'registers an offense when using string title' do
      expect_offense(<<~RUBY)
        it_behaves_like 'foo bar baz'
                        ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
        it_should_behave_like 'foo bar baz'
                              ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
        shared_examples 'foo bar baz'
                        ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
        shared_examples_for 'foo bar baz'
                            ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
        include_examples 'foo bar baz'
                         ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
        include_examples 'Foo Bar Baz'
                         ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"Foo Bar Baz"` to symbolize shared examples.
        include_examples 'foo bar baz', 'foo', 'bar'
                         ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.

        shared_examples 'foo bar baz', 'foo', 'bar' do |param|
                        ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
          # ...
        end

        RSpec.shared_examples 'foo bar baz'
                              ^^^^^^^^^^^^^ Prefer :foo_bar_baz over `"foo bar baz"` to symbolize shared examples.
      RUBY

      expect_correction(<<~RUBY)
        it_behaves_like :foo_bar_baz
        it_should_behave_like :foo_bar_baz
        shared_examples :foo_bar_baz
        shared_examples_for :foo_bar_baz
        include_examples :foo_bar_baz
        include_examples :foo_bar_baz
        include_examples :foo_bar_baz, 'foo', 'bar'

        shared_examples :foo_bar_baz, 'foo', 'bar' do |param|
          # ...
        end

        RSpec.shared_examples :foo_bar_baz
      RUBY
    end

    it 'does not register an offense when using symbol' do
      expect_no_offenses(<<~RUBY)
        it_behaves_like :foo_bar_baz
        it_should_behave_like :foo_bar_baz
        shared_examples :foo_bar_baz
        shared_examples_for :foo_bar_baz
        include_examples :foo_bar_baz
        include_examples :foo_bar_baz, :foo, :bar

        shared_examples :foo_bar_baz, 'foo', 'bar', 'foo bar', 5 do |param|
          # ...
        end

        RSpec.shared_examples :foo_bar_baz
      RUBY
    end

    it 'does not register an offense when using Module/Class title' do
      expect_no_offenses(<<~RUBY)
        it_behaves_like FooBarBaz
        it_should_behave_like FooBarBaz
        shared_examples FooBarBaz
        shared_examples_for FooBarBaz
        include_examples FooBarBaz
        include_examples FooBarBaz, 'foo', 'bar'

        shared_examples FooBarBaz, 'foo', 'bar', 'foo bar', 5 do |param|
          # ...
        end
      RUBY
    end

    context 'when using run_test!' do
      before do
        other_cops.dig('RSpec', 'Language', 'Includes', 'Examples')
          .push('run_test!')
      end

      it 'does not occur an error' do
        expect_no_offenses(<<~RUBY)
          run_test!
        RUBY
      end
    end
  end

  context 'with preferred methods' do
    shared_examples 'preferred method unset' do |config_key, methods|
      context "when #{config_key} is unset" do
        let(:config_val) { nil }

        methods.each do |method|
          it "does not register an offense for `#{method}`" do
            expect_no_offenses(<<~RUBY)
              #{method} 'desc'
            RUBY
          end
        end

        it 'does not register an offense for another method' do
          expect_no_offenses(<<~RUBY)
            describe
          RUBY
        end
      end
    end

    shared_examples 'preferred method set' do |config_key, methods, preferred|
      context "when #{config_key} is set" do
        let(:config_val) { preferred }

        it "does not register an offense for `#{preferred}`" do
          expect_no_offenses(<<~RUBY)
            #{preferred} 'desc'
          RUBY
        end

        (methods - [preferred]).each do |method|
          it "registers an offense and corrects for #{method}" do
            expect_offense(<<~RUBY, method: method, preferred: preferred)
              %{method} 'desc'
              ^{method} Prefer `%{preferred}` over `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              #{preferred} 'desc'
            RUBY
          end
        end

        it 'does not register an offense for another method' do
          expect_no_offenses(<<~RUBY)
            describe
          RUBY
        end

        it 'registers offenses and corrects for both issues ' \
           'when `EnforcedStyle` also offends' do
          method = (methods - [preferred]).first
          expect_offense(<<~RUBY, method: method, preferred: preferred)
            %{method} :desc
            ^{method} Prefer `%{preferred}` over `%{method}`.
            _{method} ^^^^^ Prefer 'desc' over `:desc` to titleize shared examples.
          RUBY

          expect_correction(<<~RUBY)
            #{preferred} 'desc'
          RUBY
        end
      end
    end

    shared_examples 'preferred method' do |config_key, methods, preferred|
      context "with #{config_key}" do
        let(:cop_config) do
          { 'EnforcedStyle' => 'string', config_key => config_val }
        end

        it_behaves_like 'preferred method unset', config_key, methods
        it_behaves_like 'preferred method set', config_key, methods, preferred
      end
    end

    before do
      # Set up custom aliases
      other_cops.dig('RSpec', 'Language', 'SharedGroups', 'Examples')
        .push('shared_scenarios')
      other_cops.dig('RSpec', 'Language', 'SharedGroups', 'Context')
        .push('shared_state')
      other_cops.dig('RSpec', 'Language', 'Includes', 'Examples')
        .push('include_scenarios')
      other_cops.dig('RSpec', 'Language', 'Includes', 'Context')
        .push('include_state')
    end

    it_behaves_like 'preferred method', 'PreferredExamplesMethod',
                    %w[shared_examples shared_examples_for shared_scenarios],
                    'shared_scenarios'

    it_behaves_like 'preferred method', 'PreferredContextMethod',
                    %w[shared_context shared_state],
                    'shared_state'

    it_behaves_like 'preferred method', 'PreferredIncludeExamplesMethod',
                    %w[it_behaves_like it_should_behave_like include_examples
                       include_scenarios],
                    'include_scenarios'

    it_behaves_like 'preferred method', 'PreferredIncludeContextMethod',
                    %w[include_context include_state],
                    'include_state'
  end
end
