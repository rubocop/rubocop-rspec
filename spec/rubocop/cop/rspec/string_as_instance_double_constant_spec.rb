# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::StringAsInstanceDoubleConstant,
               :config do
  context 'when using a class for instance_double' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        instance_double(Shape, area: 12)
      RUBY
    end
  end

  context 'when passing a variable to initialize instance_double' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        instance_double(type_undetectable_in_static_analysis)
      RUBY
    end
  end

  context 'when using a string for instance_double' do
    it 'replaces the string with the class' do
      expect_offense <<~RUBY
        instance_double('Shape', area: 12)
                        ^^^^^^^ Do not use a string as `instance_double` constant.
      RUBY

      expect_correction <<~RUBY
        instance_double(Shape, area: 12)
      RUBY
    end
  end
end
