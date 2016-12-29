describe RuboCop::Cop::RSpec::SingleArgumentMessageChain do
  subject(:cop) { described_class.new }

  describe 'receive_message_chain' do
    it 'reports single-argument calls' do
      expect_violation(<<-RUBY)
        before do
          allow(foo).to receive_message_chain(:one) { :two }
                        ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument
        end
      RUBY
    end

    it 'accepts multi-argument calls' do
      expect_no_violations(<<-RUBY)
        before do
          allow(foo).to receive_message_chain(:one, :two) { :three }
        end
      RUBY
    end

    it 'reports single-argument string calls' do
      expect_violation(<<-RUBY)
        before do
          allow(foo).to receive_message_chain("one") { :two }
                        ^^^^^^^^^^^^^^^^^^^^^ Use `receive` instead of calling `receive_message_chain` with a single argument
        end
      RUBY
    end

    it 'accepts multi-argument string calls' do
      expect_no_violations(<<-RUBY)
        before do
          allow(foo).to receive_message_chain("one.two") { :three }
        end
      RUBY
    end
  end

  describe 'stub_chain' do
    it 'reports single-argument calls' do
      expect_violation(<<-RUBY)
        before do
          foo.stub_chain(:one) { :two }
              ^^^^^^^^^^ Use `stub` instead of calling `stub_chain` with a single argument
        end
      RUBY
    end

    it 'accepts multi-argument calls' do
      expect_no_violations(<<-RUBY)
        before do
          foo.stub_chain(:one, :two) { :three }
        end
      RUBY
    end

    it 'reports single-argument string calls' do
      expect_violation(<<-RUBY)
        before do
          foo.stub_chain("one") { :two }
              ^^^^^^^^^^ Use `stub` instead of calling `stub_chain` with a single argument
        end
      RUBY
    end

    it 'accepts multi-argument string calls' do
      expect_no_violations(<<-RUBY)
        before do
          foo.stub_chain("one.two") { :three }
        end
      RUBY
    end
  end
end
