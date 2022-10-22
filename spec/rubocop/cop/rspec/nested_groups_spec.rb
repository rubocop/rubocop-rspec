# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::NestedGroups do
  it 'flags nested example groups defined inside `describe`' do
    expect_offense(<<-RUBY)
      describe MyClass do
        context 'when foo' do
          context 'when bar' do
            context 'when baz' do
            ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
            end
          end
        end

        context 'when qux' do
          context 'when norf' do
          end
        end
      end
    RUBY
  end

  it 'flags nested example groups' do
    expect_offense(<<-RUBY)
      example_group MyClass do
        context 'when foo' do
          context 'when bar' do
            context 'when baz' do
            ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
            end
          end
        end
      end
    RUBY
  end

  it 'flags nested example groups inside shared examples' do
    expect_offense(<<-RUBY)
      shared_examples_for 'nested like express' do
        context 'when foo' do
          context 'when bar' do
            context 'when baz' do
              context 'when qux' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
              end
            end
          end
        end
      end
    RUBY
  end

  it 'support --auto-gen-config' do
    inspect_source(<<-RUBY, 'spec/foo_spec.rb')
      describe MyClass do
        context 'when foo' do
          context 'when bar' do
            context 'when baz' do
            end
          end
        end
      end
    RUBY

    expect(cop.config_to_allow_offenses[:exclude_limit]).to eq('Max' => 4)
  end

  it 'flags example groups wrapped in classes' do
    expect_offense(<<-RUBY)
      class MyThingy
        describe MyClass do
          context 'when foo' do
            context 'when bar' do
              context 'when baz' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
              end
            end
          end
        end
      end
    RUBY
  end

  it 'flags example groups wrapped in modules' do
    expect_offense(<<-RUBY)
      module MyNamespace
        describe MyClass do
          context 'when foo' do
            context 'when bar' do
              context 'when baz' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
              end
            end
          end
        end
      end
    RUBY
  end

  context 'when Max is configured as 2' do
    let(:cop_config) do
      { 'Max' => '2' }
    end

    it 'flags two levels of nesting' do
      expect_offense(<<-RUBY)
        describe MyClass do
          context 'when foo' do
            context 'when bar' do
            ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [3/2].
              context 'when baz' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/2].
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when configured with MaxNesting' do
    let(:cop_config) do
      { 'MaxNesting' => '1' }
    end

    it 'emits a deprecation warning' do
      expect { inspect_source('describe(Foo) { }', 'foo_spec.rb') }
        .to output(
          'Configuration key `MaxNesting` for RSpec/NestedGroups is ' \
          "deprecated in favor of `Max`. Please use that instead.\n"
        ).to_stderr
    end
  end

  it 'counts nesting correctly when non-spec nesting' do
    expect_offense(<<-RUBY)
      describe MyClass do
        context 'when foo' do
          context 'when bar' do
            [].each do |i|
              context 'when baz' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
              end
            end
          end
        end
      end
    RUBY
  end

  context 'when AllowedGroups is configured as' do
    let(:cop_config) do
      { 'AllowedGroups' => ['path'] }
    end

    it 'accept nested example groups defined inside `describe`' \
       'path is not counted' do
      expect_no_offenses(<<-RUBY)
        describe MyClass do
          path '/users' do
            context 'when foo' do
              context 'when bar' do
              end
            end
          end
        end
      RUBY
    end

    it 'flags nested example groups defined inside `describe`' \
       'path is not counted but exceeded max' do
      expect_offense(<<-RUBY)
        describe MyClass do
          path '/users' do
            context 'when foo' do
              context 'when bar' do
                context 'when baz' do
                ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded [4/3].
                end
              end
            end
          end
        end
      RUBY
    end
  end
end
