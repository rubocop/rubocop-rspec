# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
RSpec.describe RuboCop::Cop::RSpec::FactoryBot::DynamicAttributeDefinedStatically do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  %w[FactoryBot FactoryGirl].each do |factory_bot|
    context "when using #{factory_bot}" do
      it 'registers an offense for offending code' do
        expect_offense(<<-RUBY)
          #{factory_bot}.define do
            factory :post do
              published_at 1.day.from_now
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to set a dynamic value to an attribute.
              status [:draft, :published].sample
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to set a dynamic value to an attribute.
              created_at 1.day.ago
              ^^^^^^^^^^^^^^^^^^^^ Use a block to set a dynamic value to an attribute.
            end
          end
        RUBY
      end

      it 'registers an offense in a trait' do
        expect_offense(<<-RUBY)
          #{factory_bot}.define do
            factory :post do
              title "Something"
              trait :published do
                published_at 1.day.from_now
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to set a dynamic value to an attribute.
              end
            end
          end
        RUBY
      end

      it 'accepts' do
        expect_no_offenses(<<-RUBY)
          #{factory_bot}.define do
            factory :post do
              trait :published do
                published_at { 1.day.from_now }
              end
              created_at { 1.day.ago }
              status :draft
              comments_count 0
              title "Static"
              description { FFaker::Lorem.paragraph(10) }
              tag Tag::MAGIC
            end
          end
        RUBY
      end

      it 'does not add offense if out of factory girl block' do
        expect_no_offenses(<<-RUBY)
          status [:draft, :published].sample
          published_at 1.day.from_now
          created_at 1.day.ago
        RUBY
      end

      bad = <<-RUBY
        #{factory_bot}.define do
          factory :post do
            status([:draft, :published].sample)
            published_at 1.day.from_now
            created_at(1.day.ago)
            updated_at Time.current
          end
        end
      RUBY

      corrected = <<-RUBY
        #{factory_bot}.define do
          factory :post do
            status { [:draft, :published].sample }
            published_at { 1.day.from_now }
            created_at { 1.day.ago }
            updated_at { Time.current }
          end
        end
      RUBY

      include_examples 'autocorrect', bad, corrected
    end
  end
end
