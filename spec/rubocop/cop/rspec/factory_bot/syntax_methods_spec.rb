# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::SyntaxMethods, :config do
  described_class::RESTRICT_ON_SEND.each do |method|
    it 'does not register an offense when used outside an example group' do
      expect_no_offenses(<<~RUBY)
        FactoryBot.#{method}(:bar)
      RUBY
    end

    it "does not register an offense for `#{method}`" do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end

    it "registers an offense for `FactoryBot.#{method}`" do
      expect_offense(<<~RUBY)
        describe Foo do
          let(:bar) { FactoryBot.#{method}(:bar) }
                      ^^^^^^^^^^^#{'^' * method.length} Use `#{method}` from `FactoryBot::Syntax::Methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        describe Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end

    it "registers an offense for `::FactoryBot.#{method}`" do
      expect_offense(<<~RUBY)
        RSpec.describe Foo do
          let(:bar) { ::FactoryBot.#{method}(:bar) }
                      ^^^^^^^^^^^^^#{'^' * method.length} Use `#{method}` from `FactoryBot::Syntax::Methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        RSpec.describe Foo do
          let(:bar) { #{method}(:bar) }
        end
      RUBY
    end
  end
end
