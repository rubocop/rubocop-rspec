# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::ContextWording do
  let(:cop_config) do
    { 'Prefixes' => %w[when with without], 'AllowedPatterns' => [] }
  end

  it 'skips describe blocks' do
    expect_no_offenses(<<~RUBY)
      describe 'the display name not present' do
      end
    RUBY
  end

  it 'finds context without `when` at the beginning' do
    expect_offense(<<~'RUBY')
      context 'the display name not present' do
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
      end
    RUBY
  end

  it 'finds context without `when` at the beginning and contains `#{}`' do
    expect_offense(<<~'RUBY')
      context "the #{display} name not present" do
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
      end
    RUBY
  end

  it 'finds context without `when` at the beginning ' \
     'and command surrounded by back ticks' do
    expect_offense(<<~'RUBY')
      context `pwd` do
              ^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
      end
    RUBY
  end

  it 'finds shared_context without `when` at the beginning' do
    expect_offense(<<~'RUBY')
      shared_context 'the display name not present' do
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
      end
    RUBY
  end

  it "skips descriptions beginning with 'when'" do
    expect_no_offenses(<<~RUBY)
      context 'when the display name is not present' do
      end
    RUBY
  end

  it "skips descriptions beginning with 'when,'" do
    expect_no_offenses(<<~RUBY)
      context 'when, for some inexplicable reason, you inject a subordinate clause' do
      end
    RUBY
  end

  it 'finds context without separate `when` at the beginning' do
    expect_offense(<<~'RUBY')
      context 'whenever you do' do
              ^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
      end
    RUBY
  end

  context 'with metadata hash' do
    it 'finds context without separate `when` at the beginning' do
      expect_offense(<<~'RUBY')
        context 'whenever you do', legend: true do
                ^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
        end
      RUBY
    end
  end

  context 'with symbol metadata' do
    it 'finds context without separate `when` at the beginning' do
      expect_offense(<<~'RUBY')
        context 'whenever you do', :legend do
                ^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
        end
      RUBY
    end
  end

  context 'with mixed metadata' do
    it 'finds context without separate `when` at the beginning' do
      expect_offense(<<~'RUBY')
        context 'whenever you do', :legend, myth: true do
                ^^^^^^^^^^^^^^^^^ Context description should match /^when\b/, /^with\b/, or /^without\b/.
        end
      RUBY
    end
  end

  context 'when configured' do
    let(:cop_config) { { 'Prefixes' => %w[if], 'AllowedPatterns' => [] } }

    it 'finds context without allowed prefixes at the beginning' do
      expect_offense(<<~'RUBY')
        context 'when display name is present' do
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Context description should match /^if\b/.
        end
      RUBY
    end

    it 'skips descriptions with allowed prefixes at the beginning' do
      expect_no_offenses(<<~RUBY)
        context 'if display name is present' do
        end
      RUBY
    end

    context 'with a multi-word prefix' do
      let(:cop_config) do
        { 'Prefixes' => ['assuming that'], 'AllowedPatterns' => [] }
      end

      it 'skips descriptions with allowed multi-word prefixes' do
        expect_no_offenses(<<~RUBY)
          context 'assuming that display name is present' do
          end
        RUBY
      end
    end

    context 'with special regex characters' do
      let(:cop_config) { { 'Prefixes' => ['a$b\d'], 'AllowedPatterns' => [] } }

      it 'matches the full prefix' do
        expect_offense(<<~'RUBY')
          context 'a' do
                  ^^^ Context description should match /^a\$b\\d\b/.
          end
        RUBY
      end

      it 'matches special characters' do
        expect_no_offenses(<<~'RUBY')
          context 'a$b\d something' do
          end
        RUBY
      end
    end

    context 'when `AllowedPatterns: [とき$]`' do
      let(:cop_config) do
        { 'Prefixes' => [], 'AllowedPatterns' => ['とき$'] }
      end

      it 'finds context without `とき` at the ending' do
        expect_offense(<<~RUBY)
          context '条件を満たす' do
                  ^^^^^^^^ Context description should match /とき$/.
          end
        RUBY
      end

      it 'finds shared_context without `とき` at the ending' do
        expect_offense(<<~RUBY)
          shared_context '条件を満たす' do
                         ^^^^^^^^ Context description should match /とき$/.
          end
        RUBY
      end

      it "skips descriptions ending with 'とき'" do
        expect_no_offenses(<<~RUBY)
          context '条件を満たすとき' do
          end
        RUBY
      end
    end

    context 'when `Prefixes: [when]` and `AllowedPatterns: [patterns]`' do
      let(:cop_config) do
        { 'Prefixes' => %w[when], 'AllowedPatterns' => ['patterns'] }
      end

      it 'finds context without `when` at the beginning and not included ' \
         '`/patterns/`' do
        expect_offense(<<~'RUBY')
          context 'this is an incorrect context' do
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Context description should match /patterns/, or /^when\b/.
          end
        RUBY
      end

      it 'finds shared_context without `when` at the beginning and ' \
         'not included `/patterns/`' do
        expect_offense(<<~'RUBY')
          shared_context 'this is an incorrect context' do
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Context description should match /patterns/, or /^when\b/.
          end
        RUBY
      end

      it "skips descriptions beginning with 'when'" do
        expect_no_offenses(<<~RUBY)
          context 'when this is valid context' do
          end
        RUBY
      end

      it "skips descriptions include with 'patterns'" do
        expect_no_offenses(<<~RUBY)
          context 'this is valid patterns context' do
          end
        RUBY
      end
    end
  end

  context 'when `AllowedPatterns:` and `Prefixes:` are both empty' do
    let(:cop_config) do
      { 'Prefixes' => [], 'AllowedPatterns' => [] }
    end

    it 'always registers an offense' do
      expect_offense(<<~RUBY)
        context 'this is an incorrect context' do
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Current settings will always report an offense. Please add allowed words to `Prefixes` or `AllowedPatterns`.
        end
      RUBY
    end
  end

  context 'when `Prefixes: [on]' do
    let(:cop_config) do
      YAML.safe_load(<<-CONFIG)
        Prefixes:
          - on # evaluates to true
      CONFIG
    end

    it 'fails' do
      expect do
        expect_no_offenses(<<~RUBY)
          context 'on Linux' do
          end
        RUBY
      end.to raise_error(/Non-string prefixes .+ detected/)
    end
  end

  context 'when `Prefixes: ["on"]' do
    let(:cop_config) do
      YAML.safe_load(<<-CONFIG)
        Prefixes:
          - "on"
      CONFIG
    end

    it 'does not fail' do
      expect { expect_no_offenses(<<~RUBY) }.not_to raise_error
        context 'on Linux' do
        end
      RUBY
    end
  end
end
