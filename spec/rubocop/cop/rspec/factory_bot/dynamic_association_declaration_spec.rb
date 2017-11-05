# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
RSpec.describe RuboCop::Cop::RSpec::FactoryBot::DynamicAssociationDeclaration do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for offending code' do
    expect_offense(<<-RUBY)
      FactoryGirl.define do
        factory :post do
          author
          ^^^^^^ Use `association :author` to declare association.
          category
          ^^^^^^^^ Use `association :category` to declare association.
        end
      end
    RUBY
  end

  it 'registers an offense for offending code in a trait' do
    expect_offense(<<-RUBY)
      FactoryGirl.define do
        factory :post do
          title "Something"
          trait :commented do
            comments
            ^^^^^^^^ Use `association :comments` to declare association.
          end
        end
      end
    RUBY
  end

  it 'does not add an offense for non-offending code' do
    expect_no_offenses(<<-RUBY)
      FactoryGirl.define do
        factory :post do
          association :author, strategy: :build
          association :comments
        end
      end
    RUBY
  end

  it 'does not add an offense for a FactoryBot method' do
    expect_no_offenses(<<-RUBY)
      FactoryGirl.define do
        factory :post do
          skip_create
        end
      end
    RUBY
  end

  it 'does not add an offense for offensive code outside of FactoryBot definitions' do
    expect_no_offenses(<<-RUBY)
      comments
    RUBY
  end

  bad = <<-RUBY
    FactoryGirl.define do
      factory :post do
        comments
      end
    end
  RUBY

  corrected = <<-RUBY
    FactoryGirl.define do
      factory :post do
        association :comments
      end
    end
  RUBY

  include_examples 'autocorrect', bad, corrected
end
