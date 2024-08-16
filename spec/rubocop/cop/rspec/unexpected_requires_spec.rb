# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::UnexpectedRequires do
  context 'when there is an require' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        require "base64"
        ^^^^^^^ Do not require anything in a test file.

        describe "MyTest" do
          do_something
        end
      RUBY
    end

    context 'with the file being spec_helper' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, "spec/spec_helper.rb")
          require "base64"

          describe "MyTest" do
          end
        RUBY
      end
    end

    context 'with the file being rails_helper' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'spec/rails_helper.rb')
          require "rails"

          describe "MyTest" do
          end
        RUBY
      end
    end
  end

  context 'when no requires are there' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        describe "MyTest" do
        end
      RUBY
    end
  end
end
