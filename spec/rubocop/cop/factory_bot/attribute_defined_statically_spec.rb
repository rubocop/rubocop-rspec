# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::AttributeDefinedStatically do
  def inspected_source_filename
    'spec/factories.rb'
  end

  it 'registers an offense for offending code' do
    expect_offense(<<-RUBY)
      FactoryBot.define do
        factory :post do
          title "Something"
          ^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          comments_count 0
          ^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          tag Tag::MAGIC
          ^^^^^^^^^^^^^^ Use a block to declare attribute values.
          recent_statuses []
          ^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          status([:draft, :published].sample)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          published_at 1.day.from_now
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          created_at(1.day.ago)
          ^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          update_times [Time.current]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          meta_tags(foo: Time.current)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          other_tags({ foo: Time.current })
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          options color: :blue
          ^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          other_options Tag::MAGIC => :magic
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      FactoryBot.define do
        factory :post do
          title { "Something" }
          comments_count { 0 }
          tag { Tag::MAGIC }
          recent_statuses { [] }
          status { [:draft, :published].sample }
          published_at { 1.day.from_now }
          created_at { 1.day.ago }
          update_times { [Time.current] }
          meta_tags { { foo: Time.current } }
          other_tags { { foo: Time.current } }
          options { { color: :blue } }
          other_options { { Tag::MAGIC => :magic } }
        end
      end
    RUBY
  end

  it 'registers an offense in a trait' do
    expect_offense(<<-RUBY)
      FactoryBot.define do
        factory :post do
          trait :published do
            title "Something"
            ^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
            published_at 1.day.from_now
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          end
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      FactoryBot.define do
        factory :post do
          trait :published do
            title { "Something" }
            published_at { 1.day.from_now }
          end
        end
      end
    RUBY
  end

  it 'registers an offense in a transient block' do
    expect_offense(<<-RUBY)
      FactoryBot.define do
        factory :post do
          transient do
            title "Something"
            ^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
            published_at 1.day.from_now
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          end
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      FactoryBot.define do
        factory :post do
          transient do
            title { "Something" }
            published_at { 1.day.from_now }
          end
        end
      end
    RUBY
  end

  it 'registers an offense for an attribute defined on `self`' do
    expect_offense(<<-RUBY)
      FactoryBot.define do
        factory :post do
          self.start { Date.today }
          self.end Date.tomorrow
          ^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      FactoryBot.define do
        factory :post do
          self.start { Date.today }
          self.end { Date.tomorrow }
        end
      end
    RUBY
  end

  it 'registers an offense for attributes defined on explicit receiver' do
    expect_offense(<<-RUBY)
      FactoryBot.define do
        factory :post do |post_definition|
          post_definition.end Date.tomorrow
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          post_definition.trait :published do |published_definition|
            published_definition.published_at 1.day.from_now
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a block to declare attribute values.
          end
        end
      end
    RUBY

    expect_correction(<<-RUBY)
      FactoryBot.define do
        factory :post do |post_definition|
          post_definition.end { Date.tomorrow }
          post_definition.trait :published do |published_definition|
            published_definition.published_at { 1.day.from_now }
          end
        end
      end
    RUBY
  end

  it 'accepts valid factory definitions' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :post do
          trait :published do
            published_at { 1.day.from_now }
          end
          created_at { 1.day.ago }
          status { :draft }
          comments_count { 0 }
          title { "Static" }
          description { FFaker::Lorem.paragraph(10) }
          recent_statuses { [] }
          tags { { like_count: 2 } }

          before(:create, &:initialize_something)
          after(:create, &:rebuild_cache)
        end
      end
    RUBY
  end

  it 'does not add offense if out of factory bot block' do
    expect_no_offenses(<<-RUBY)
      status [:draft, :published].sample
      published_at 1.day.from_now
      created_at 1.day.ago
      update_times [Time.current]
      meta_tags(foo: Time.current)
    RUBY
  end

  it 'does not add offense if method called on another object' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :post do |post_definition|
          Registrar.register :post_factory
        end
      end
    RUBY
  end

  it 'does not add offense if method called on a local variable' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :post do |post_definition|
          local = Registrar
          local.register :post_factory
        end
      end
    RUBY
  end

  it 'accepts valid association definitions' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :post do
          author age: 42, factory: :user
        end
      end
    RUBY
  end

  it 'accepts valid sequence definition' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :post do
          sequence :negative_numbers, &:-@
        end
      end
    RUBY
  end

  it 'accepts valid traits_for_enum definition' do
    expect_no_offenses(<<-RUBY)
      FactoryBot.define do
        factory :post do
          traits_for_enum :status, [:draft, :published]
        end
      end
    RUBY
  end
end
