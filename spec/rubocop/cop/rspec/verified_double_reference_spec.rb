# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::VerifiedDoubleReference do
  verified_doubles = %w[
    class_double
    class_spy
    instance_double
    instance_spy
    mock_model
    object_double
    object_spy
    stub_model
  ]

  verified_doubles.each do |verified_double|
    describe verified_double do
      context 'when EnforcedStyle is constant' do
        let(:cop_config) do
          { 'EnforcedStyle' => 'constant' }
        end

        it 'does not flag a violation when using a constant reference' do
          expect_no_offenses("#{verified_double}(ClassName)")
        end

        it 'flags a violation when using a string reference' do
          expect_offense(<<~RUBY, verified_double: verified_double)
            %{verified_double}('ClassName')
            _{verified_double} ^^^^^^^^^^^ Use a constant class reference for verified doubles.
            %{verified_double}('Foo::Bar::Baz')
            _{verified_double} ^^^^^^^^^^^^^^^ Use a constant class reference for verified doubles.
            %{verified_double}('::Foo::Bar')
            _{verified_double} ^^^^^^^^^^^^ Use a constant class reference for verified doubles.
          RUBY

          expect_correction(<<~RUBY)
            #{verified_double}(ClassName)
            #{verified_double}(Foo::Bar::Baz)
            #{verified_double}(::Foo::Bar)
          RUBY
        end

        include_examples 'detects style',
                         "#{verified_double}(ClassName)",
                         'constant'
      end

      context 'when EnforcedStyle is string' do
        let(:cop_config) do
          { 'EnforcedStyle' => 'string' }
        end

        it 'does not flag a violation when using a string reference' do
          expect_no_offenses("#{verified_double}('ClassName')")
        end

        it 'flags a violation when using a constant reference' do
          expect_offense(<<~RUBY, verified_double: verified_double)
            %{verified_double}(ClassName)
            _{verified_double} ^^^^^^^^^ Use a string class reference for verified doubles.
            %{verified_double}(Foo::Bar::Baz)
            _{verified_double} ^^^^^^^^^^^^^ Use a string class reference for verified doubles.
            %{verified_double}(::Foo::Bar)
            _{verified_double} ^^^^^^^^^^ Use a string class reference for verified doubles.
          RUBY

          expect_correction(<<~RUBY)
            #{verified_double}('ClassName')
            #{verified_double}('Foo::Bar::Baz')
            #{verified_double}('::Foo::Bar')
          RUBY
        end

        include_examples 'detects style',
                         "#{verified_double}('ClassName')",
                         'string'
      end
    end
  end

  it 'does not flag a violation when reference is not a supported style' do
    expect_no_offenses(<<~RUBY)
      klass = Array
      instance_double(klass)

      @sut = Array
      let(:double) { instance_double(@sut) }

      object_double([])

      class_double(:Model)
    RUBY
  end
end
