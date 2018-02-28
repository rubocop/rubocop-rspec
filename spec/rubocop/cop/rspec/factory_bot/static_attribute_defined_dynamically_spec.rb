# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
RSpec.describe RuboCop::Cop::RSpec::FactoryBot::StaticAttributeDefinedDynamically do
  # rubocop:enable Metrics/LineLength

  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  %w[FactoryBot FactoryGirl].each do |factory_bot|
    context "when using #{factory_bot}" do
      it 'registers an offense for offending code' do
        expect_offense(<<-RUBY)
          #{factory_bot}.define do
            factory :post do
              kind { :static }
              ^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              comments_count { 0 }
              ^^^^^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              type { User::MAGIC }
              ^^^^^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              description { nil }
              ^^^^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              recent_statuses { [:published, :draft] }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              meta_tags { { foo: 1 } }
              ^^^^^^^^^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              title {}
              ^^^^^^^^ Do not use a block to set a static value to an attribute.
            end
          end
        RUBY
      end

      it 'registers an offense in a trait' do
        expect_offense(<<-RUBY)
          #{factory_bot}.define do
            factory :post do
              title "Something"
              trait :something_else do
                title { "Something Else" }
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use a block to set a static value to an attribute.
              end
            end
          end
        RUBY
      end

      it 'accepts valid factory definitions' do
        expect_no_offenses(<<-RUBY)
          #{factory_bot}.define do
            factory :post do
              trait :something_else do
                title "Something Else"
              end
              title "Something"
              comments_count 0
              description { FFaker::Lorem.paragraph(10) }
              tag Tag::MAGIC
              recent_updates { [Time.current] }
              meta_tags { { first_like: Time.current } }
              before(:create) { 'foo' }
            end
          end
        RUBY
      end

      it 'does not add offense if out of factory girl block' do
        expect_no_offenses(<<-RUBY)
          kind { :static }
          comments_count { 0 }
          type { User::MAGIC }
          description { nil }
        RUBY
      end

      bad = <<-RUBY
        #{factory_bot}.define do
          factory :post do
            comments_count { 0 }
            type { User::MAGIC }
            description { nil }
            title {}
            recent_statuses { [:published, :draft] }
            meta_tags { { foo: 1 } }
          end
        end
      RUBY

      corrected = <<-RUBY
        #{factory_bot}.define do
          factory :post do
            comments_count 0
            type User::MAGIC
            description nil
            title nil
            recent_statuses [:published, :draft]
            meta_tags({ foo: 1 })
          end
        end
      RUBY

      include_examples 'autocorrect', bad, corrected
    end
  end
end
