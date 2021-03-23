# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ContextWording do
  let(:cop_config) { { 'Prefixes' => %w[when with] } }

  it 'skips describe blocks' do
    expect_no_offenses(<<-RUBY)
      describe 'the display name not present' do
      end
    RUBY
  end

  it 'finds context without `when` at the beginning' do
    expect_offense(<<-RUBY)
      context 'the display name not present' do
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Start context description with 'when', or 'with'.
      end
    RUBY
  end

  it 'finds shared_context without `when` at the beginning' do
    expect_offense(<<-RUBY)
      shared_context 'the display name not present' do
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Start context description with 'when', or 'with'.
      end
    RUBY
  end

  it "skips descriptions beginning with 'when'" do
    expect_no_offenses(<<-RUBY)
      context 'when the display name is not present' do
      end
    RUBY
  end

  it "skips descriptions beginning with 'when,'" do
    expect_no_offenses(<<-RUBY)
      context 'when, for some inexplicable reason, you inject a subordinate clause' do
      end
    RUBY
  end

  it 'finds context without separate `when` at the beginning' do
    expect_offense(<<-RUBY)
      context 'whenever you do' do
              ^^^^^^^^^^^^^^^^^ Start context description with 'when', or 'with'.
      end
    RUBY
  end

  context 'with metadata hash' do
    it 'finds context without separate `when` at the beginning' do
      expect_offense(<<-RUBY)
        context 'whenever you do', legend: true do
                ^^^^^^^^^^^^^^^^^ Start context description with 'when', or 'with'.
        end
      RUBY
    end
  end

  context 'with symbol metadata' do
    it 'finds context without separate `when` at the beginning' do
      expect_offense(<<-RUBY)
        context 'whenever you do', :legend do
                ^^^^^^^^^^^^^^^^^ Start context description with 'when', or 'with'.
        end
      RUBY
    end
  end

  context 'with mixed metadata' do
    it 'finds context without separate `when` at the beginning' do
      expect_offense(<<-RUBY)
        context 'whenever you do', :legend, myth: true do
                ^^^^^^^^^^^^^^^^^ Start context description with 'when', or 'with'.
        end
      RUBY
    end
  end

  context 'when configured' do
    let(:cop_config) { { 'Prefixes' => %w[if] } }

    it 'finds context without allowed prefixes at the beginning' do
      expect_offense(<<-RUBY)
        context 'when display name is present' do
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Start context description with 'if'.
        end
      RUBY
    end

    it 'skips descriptions with allowed prefixes at the beginning' do
      expect_no_offenses(<<-RUBY)
        context 'if display name is present' do
        end
      RUBY
    end

    context 'with a multi-word prefix' do
      let(:cop_config) { { 'Prefixes' => ['assuming that'] } }

      it 'skips descriptions with allowed multi-word prefixes' do
        expect_no_offenses(<<-RUBY)
          context 'assuming that display name is present' do
          end
        RUBY
      end
    end

    context 'with special regex characters' do
      let(:cop_config) { { 'Prefixes' => ['a$b\d'] } }

      it 'matches the full prefix' do
        expect_offense(<<-RUBY)
          context 'a' do
                  ^^^ Start context description with 'a$b\\d'.
          end
        RUBY
      end

      it 'matches special characters' do
        expect_no_offenses(<<-RUBY)
          context 'a$b\\d something' do
          end
        RUBY
      end
    end
  end
end
