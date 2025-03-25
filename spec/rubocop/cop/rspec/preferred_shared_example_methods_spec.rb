# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::PreferredSharedExampleMethods, :config do
  shared_examples 'preferred method' do |config_key, preferred:,
                                         methods:, opposing_methods:|
    context "with #{config_key}" do
      let(:cop_config) do
        { config_key => config_val }
      end

      context "when #{config_key} is unset" do
        let(:config_val) { nil }

        ([preferred] + methods + opposing_methods).each do |method|
          it "does not register an offense for `#{method}`" do
            expect_no_offenses(<<~RUBY)
              #{method} 'desc'
            RUBY
          end

          it "does not register an offense for `RSpec.#{method}`" do
            expect_no_offenses(<<~RUBY)
              RSpec.#{method} 'desc'
            RUBY
          end
        end

        it 'does not register an offense for an unrelated method call' do
          expect_no_offenses(<<~RUBY)
            describe
          RUBY
        end
      end

      context "when #{config_key} is set" do
        let(:config_val) { preferred }

        it "does not register an offense for `#{preferred}`" do
          expect_no_offenses(<<~RUBY)
            #{preferred} 'desc'
          RUBY
        end

        it "does not register an offense for `RSpec.#{preferred}`" do
          expect_no_offenses(<<~RUBY)
            RSpec.#{preferred} 'desc'
          RUBY
        end

        methods.each do |method|
          it "registers an offense and corrects for `#{method}`" do
            expect_offense(<<~RUBY, method: method, preferred: preferred)
              %{method} 'desc'
              ^{method} Prefer `%{preferred}` over `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              #{preferred} 'desc'
            RUBY
          end

          it "registers an offense and corrects for `RSpec.#{method}`" do
            expect_offense(<<~RUBY, method: method, preferred: preferred)
              RSpec.%{method} 'desc'
                    ^{method} Prefer `%{preferred}` over `%{method}`.
            RUBY

            expect_correction(<<~RUBY)
              RSpec.#{preferred} 'desc'
            RUBY
          end
        end

        opposing_methods.each do |method|
          it "does not register an offense for `#{method}`" do
            expect_no_offenses(<<~RUBY)
              #{method} 'desc'
            RUBY
          end

          it "does not register an offense for `RSpec.#{method}`" do
            expect_no_offenses(<<~RUBY)
              RSpec.#{method} 'desc'
            RUBY
          end
        end

        it 'does not register an offense for an unrelated method call' do
          expect_no_offenses(<<~RUBY)
            describe
          RUBY
        end
      end
    end
  end

  before do
    # Set up custom aliases
    other_cops.dig('RSpec', 'Language', 'SharedGroups', 'Examples')
      .push('shared_scenarios')
    other_cops.dig('RSpec', 'Language', 'SharedGroups', 'Context')
      .push('shared_state')
  end

  it_behaves_like 'preferred method', 'PreferredExamplesMethod',
                  preferred: 'shared_scenarios',
                  methods: %w[shared_examples shared_examples_for],
                  opposing_methods: %w[shared_context shared_state]

  it_behaves_like 'preferred method', 'PreferredContextMethod',
                  preferred: 'shared_state',
                  methods: %w[shared_context],
                  opposing_methods: %w[shared_examples shared_examples_for
                                       shared_scenarios]
end
