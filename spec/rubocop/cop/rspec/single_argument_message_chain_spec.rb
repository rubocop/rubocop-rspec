# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SingleArgumentMessageChain do
  subject(:cop) { described_class.new }

  describe 'receive_message_chain' do
    it 'reports single-argument calls' do
      expect_offense(<<-RUBY)
        before do
          allow(foo).to receive_message_chain(:one) { :two }
                        ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument.
        end
      RUBY

      expect_correction(<<-RUBY)
        before do
          allow(foo).to receive(:one) { :two }
        end
      RUBY
    end

    it 'accepts multi-argument calls' do
      expect_no_offenses(<<-RUBY)
        before do
          allow(foo).to receive_message_chain(:one, :two) { :three }
        end
      RUBY
    end

    it 'reports single-argument string calls' do
      expect_offense(<<-RUBY)
        before do
          allow(foo).to receive_message_chain("one") { :two }
                        ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument.
        end
      RUBY

      expect_correction(<<-RUBY)
        before do
          allow(foo).to receive("one") { :two }
        end
      RUBY
    end

    it 'accepts multi-argument string calls' do
      expect_no_offenses(<<-RUBY)
        before do
          allow(foo).to receive_message_chain("one.two") { :three }
        end
      RUBY
    end

    it 'accepts single-argument calls with variable' do
      expect_no_offenses(<<-RUBY)
        before do
          foo = %i[:one :two]
          allow(foo).to receive_message_chain(foo) { :many }
        end
      RUBY
    end

    it 'accepts single-argument calls with send node' do
      expect_no_offenses(<<-RUBY)
        before do
          allow(foo).to receive_message_chain(foo) { :many }
        end
      RUBY
    end

    context 'with single-element array argument' do
      it 'reports an offense' do
        expect_offense(<<-RUBY)
          before do
            allow(foo).to receive_message_chain([:one]) { :two }
                          ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument.
          end
        RUBY

        expect_correction(<<-RUBY)
          before do
            allow(foo).to receive(:one) { :two }
          end
        RUBY
      end
    end

    context 'with multiple-element array argument' do
      it "doesn't report an offense" do
        expect_no_offenses(<<-RUBY)
          before do
            allow(foo).to receive_message_chain([:one, :two]) { :many }
          end
        RUBY
      end
    end

    context 'with single-key hash argument' do
      it 'reports an offense' do
        expect_offense(<<-RUBY)
          before do
            allow(foo).to receive_message_chain(bar: 42)
                          ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument.
            allow(foo).to receive_message_chain("bar" => 42)
                          ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument.
            allow(foo).to receive_message_chain(:"\#{foo}" => 42)
                          ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument.
          end
        RUBY

        expect_correction(<<-RUBY)
          before do
            allow(foo).to receive(:bar).and_return(42)
            allow(foo).to receive("bar").and_return(42)
            allow(foo).to receive(:"\#{foo}").and_return(42)
          end
        RUBY
      end
    end

    context 'with multiple keys hash argument' do
      it "doesn't report an offense" do
        expect_no_offenses(<<-RUBY)
          before do
            allow(foo).to receive_message_chain(bar: 42, baz: 42)
          end
        RUBY
      end
    end
  end

  describe 'stub_chain' do
    it 'reports single-argument calls' do
      expect_offense(<<-RUBY)
        before do
          foo.stub_chain(:one) { :two }
              ^^^^^^^^^^ Use `stub` instead of calling `stub_chain` with a single argument.
        end
      RUBY

      expect_correction(<<-RUBY)
        before do
          foo.stub(:one) { :two }
        end
      RUBY
    end

    it 'accepts multi-argument calls' do
      expect_no_offenses(<<-RUBY)
        before do
          foo.stub_chain(:one, :two) { :three }
        end
      RUBY
    end

    it 'reports single-argument string calls' do
      expect_offense(<<-RUBY)
        before do
          foo.stub_chain("one") { :two }
              ^^^^^^^^^^ Use `stub` instead of calling `stub_chain` with a single argument.
        end
      RUBY

      expect_correction(<<-RUBY)
        before do
          foo.stub("one") { :two }
        end
      RUBY
    end

    it 'accepts multi-argument string calls' do
      expect_no_offenses(<<-RUBY)
        before do
          foo.stub_chain("one.two") { :three }
        end
      RUBY
    end
  end
end
