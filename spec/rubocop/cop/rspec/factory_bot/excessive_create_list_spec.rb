# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubocop::Cop::RSpec::FactoryBot::ExcessiveCreateList do
  let(:cop_config) do
    { 'MaxAmount' => max_amount }
  end

  context 'when MaxAmount is set to 50' do
    let(:max_amount) { 50 }

    it 'ignores code that does not contain create_list' do
      expect_no_offenses(<<~RUBY)
        expect(true).to be_truthy
      RUBY
    end

    it 'ignores create_list with non-integer value' do
      expect_no_offenses(<<~RUBY)
        create_list(:merge_requests, value)
      RUBY
    end

    it 'ignores create_list with less than 50 items' do
      expect_no_offenses(<<~RUBY)
        create_list(:merge_requests, 30)
      RUBY
    end

    it 'ignores create_list for 50 items' do
      expect_no_offenses(<<~RUBY)
        create_list(:merge_requests, 50)
      RUBY
    end

    it 'registers an offense for create_list for more than 50 items' do
      expect_offense(<<~RUBY)
        create_list(:merge_requests, 51)
                                     ^^ Avoid using `create_list` with more than 50 items.
      RUBY
    end
  end
end
