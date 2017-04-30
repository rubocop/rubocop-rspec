RSpec.describe RuboCop::Cop::RSpec::DescribeMethod, :config do
  subject(:cop) { described_class.new(config) }

  context 'when not describing a class' do
    it 'ignores describe names' do
      expect_no_violations(<<-RUBY)
        describe 'garden' do
          describe 'flowers' do; end
          describe 'trees' do; end
        end
      RUBY
    end
  end

  context 'when describing a class' do
    it 'ignores describes with only a class' do
      expect_no_violations('describe Some::Class do; end')
    end

    it 'skips example arguments' do
      expect_no_violations(<<-RUBY)
        describe Some::Class do
          it 'does something' do; end
        end
      RUBY
    end

    it 'skips descriptions of class and instance methods' do
      expect_no_violations(<<-RUBY)
        describe Some::Class do
          describe '.perform' do; end
          describe '#clean' do; end
        end
      RUBY
    end

    it 'skips included example nodes' do
      expect_no_violations(<<-RUBY)
        describe Some::Class do
          include_examples 'BA::Talent::Walkthrough::WorkingHours::Step'
        end
      RUBY
    end

    it 'skips empty example groups' do
      expect_no_violations(<<-RUBY)
        describe Some::Class do
        end
      RUBY
    end

    it 'skips constants' do
      expect_no_violations(<<-RUBY)
        describe Some::Class do
          describe Some::Class::Hooks do
            it { is_expected.to do_stuff }
          end
        end
      RUBY
    end

    context 'when ignored describe names present' do
      let(:cop_config) do
        { 'IgnoredDescribes' => %w[flowers stars] }
      end

      it 'skips ignored describes' do
        expect_no_violations(<<-RUBY)
          describe Some::Class do
            describe 'flowers' do; end
            describe 'stars' do; end
          end
        RUBY
      end

      it 'complains about non-method names' do
        expect_violation(<<-RUBY)
          describe Some::Class do
            describe 'flowers' do; end
            describe 'trees' do; end
                     ^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.

          end
        RUBY
      end

      it 'skips ignored describe arguments' do
        expect_no_violations(<<-RUBY)
            describe Some::Class, 'flowers' do; end
        RUBY
      end

      it 'complains about non-method describe arguments' do
        expect_violation(<<-RUBY)
            describe Some::Class, 'flowers' do; end
            describe Some::Class, 'trees' do; end
                                  ^^^^^^^ The second argument to describe should be the method being tested: '#instance' or '.class'.
        RUBY
      end
    end

    context 'when untitled describe' do
      it 'enforces non-empty describes' do
        expect_violation(<<-RUBY)
          describe Some::Class do
            describe do; end
            ^^^^^^^^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
          end
        RUBY
      end

      it 'correctly marks multiline describe' do
        expect_violation(<<-RUBY)
          describe Some::Class do
            describe do
            ^^^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
              it { is_expected.to do_stuff }
            end
          end
        RUBY
      end
    end

    context 'when single second level describe present' do
      it 'complains about non-method names' do
        expect_violation(<<-RUBY)
          describe Some::Class do
            describe 'flowers' do; end
                     ^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
          end
        RUBY
      end
    end

    context 'when multiple second level describes present' do
      it 'complains about non-method names' do
        expect_violation(<<-RUBY)
          describe Some::Class do
            describe '.perform' do; end
            describe 'flowers' do; end
                     ^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
          end
        RUBY
      end
    end

    context 'when multiple describe arguments present' do
      it 'complains about non-method names' do
        expect_violation(<<-RUBY)
          describe Some::Class do
            describe '.something', 'flowers' do
                                   ^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
              it { is_expected.to do_stuff }
            end
          end
        RUBY
      end
    end

    context 'when deeply nested class describes present' do
      it 'complains about non-method names' do
        expect_violation(<<-RUBY)
          describe SomeClass do
            describe SomeClass::SubClass do
              describe '.perform' do; end
              describe 'flowers' do; end
                       ^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
            end
          end
        RUBY
      end

      it 'complains about non-method names passed as arguments to desribe' do
        expect_violation(<<-RUBY)
          describe SomeClass do
            describe SomeClass::SubClass, '.perform' do; end
            describe SomeClass::SubClass, 'flowers' do; end
                                          ^^^^^^^^^ The second level describes should be the method being tested: '#instance' or '.class'.
          end
        RUBY
      end
    end
  end

  context 'when description is passed as second argument to describe' do
    it 'complains non-method names' do
      expect_violation(<<-RUBY)
        describe Some::Class, 'nope', '.incorrect_usage' do
                              ^^^^^^ The second argument to describe should be the method being tested: '#instance' or '.class'.
        end
      RUBY
    end

    it 'skips methods starting with a . or #' do
      expect_no_violations(<<-RUBY)
        describe Some::Class, '.asdf' do
        end

        describe Some::Class, '#fdsa' do
        end
      RUBY
    end

    it 'skips specs not having a string second argument' do
      expect_no_violations(<<-RUBY)
        describe Some::Class, :config do
        end
      RUBY
    end

    context 'when multiple top level describes present' do
      it 'complains about non-method names' do
        expect_violation(<<-RUBY)
          describe SomeClass::SubClass, '.perform' do; end
          describe SomeClass::SubClass, 'flowers' do; end
                                        ^^^^^^^^^ The second argument to describe should be the method being tested: '#instance' or '.class'.
        RUBY
      end
    end
  end
end
