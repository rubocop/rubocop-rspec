# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
RSpec.describe RuboCop::Cop::RSpec::FactoryBot::DynamicAttributeDefinedStatically do
  # rubocop:enable Metrics/LineLength

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
              update_times [Time.current]
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to set a dynamic value to an attribute.
              meta_tags(foo: Time.current)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to set a dynamic value to an attribute.
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

      it 'accepts valid factory definitions' do
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
              recent_statuses [:published, :draft]
              meta_tags(like_count: 2)
              other_tags({ foo: nil })

              before(:create, &:initialize_something)
              after(:create, &:rebuild_cache)
            end
          end
        RUBY
      end

      it 'accepts const as a static value' do
        expect_no_offenses(<<-RUBY)
          #{factory_bot}.define do
            factory(:post, class: PrivatePost) do
              tag Tag::MAGIC
              options({priority: Priotity::HIGH})
            end
          end
        RUBY
      end

      it 'does not add offense if out of factory girl block' do
        expect_no_offenses(<<-RUBY)
          status [:draft, :published].sample
          published_at 1.day.from_now
          created_at 1.day.ago
          update_times [Time.current]
          meta_tags(foo: Time.current)
        RUBY
      end

      bad = <<-RUBY
        #{factory_bot}.define do
          factory :post do
            status([:draft, :published].sample)
            published_at 1.day.from_now
            created_at(1.day.ago)
            updated_at Time.current
            update_times [Time.current]
            meta_tags(foo: Time.current)
            other_tags({ foo: Time.current })

            trait :old do
              published_at 1.week.ago
            end
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
            update_times { [Time.current] }
            meta_tags { { foo: Time.current } }
            other_tags { { foo: Time.current } }

            trait :old do
              published_at { 1.week.ago }
            end
          end
        end
      RUBY

      include_examples 'autocorrect', bad, corrected
    end
  end
end
