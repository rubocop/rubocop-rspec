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
      context 'with requirement to use constant class references' do
        it 'does not flag an offense when using a constant reference' do
          expect_no_offenses("#{verified_double}(ClassName)")
        end

        it 'flags an offense when using a string reference' do
          expect_offense(<<~RUBY, verified_double: verified_double)
            %{verified_double}('ClassName')
            _{verified_double} ^^^^^^^^^^^ Use a constant class reference for verified doubles. String references are not verifying unless the class is loaded.
            %{verified_double}('Foo::Bar::Baz')
            _{verified_double} ^^^^^^^^^^^^^^^ Use a constant class reference for verified doubles. String references are not verifying unless the class is loaded.
            %{verified_double}('::Foo::Bar')
            _{verified_double} ^^^^^^^^^^^^ Use a constant class reference for verified doubles. String references are not verifying unless the class is loaded.
          RUBY

          expect_correction(<<~RUBY)
            #{verified_double}(ClassName)
            #{verified_double}(Foo::Bar::Baz)
            #{verified_double}(::Foo::Bar)
          RUBY
        end
      end
    end
  end

  it 'does not flag an offense when reference is not a supported style' do
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
