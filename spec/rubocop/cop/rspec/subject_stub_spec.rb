# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SubjectStub do
  it 'flags when subject is stubbed' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        before do
          allow(foo).to receive(:bar).and_return(baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end

        it 'uses expect twice' do
          expect(foo.bar).to eq(baz)
        end
      end
    RUBY
  end

  it 'flags when subject is stubbed and there are several named subjects ' \
     'in the same example group' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }
        subject(:bar) { described_class.new }
        subject(:baz) { described_class.new }

        before do
          allow(bar).to receive(:bar).and_return(baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end

        it 'uses expect twice' do
          expect(foo.bar).to eq(baz)
        end
      end
    RUBY
  end

  it 'flags when subject is mocked' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        before do
          expect(foo).to receive(:bar).and_return(baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo).to receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo).to receive(:bar).with(1)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo).to receive(:bar).with(1).and_return(2)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end

        it 'uses expect twice' do
          expect(foo.bar).to eq(baz)
        end
      end
    RUBY
  end

  it 'flags when an unnamed subject is mocked' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject { described_class.new }

        it 'uses unnamed subject' do
          expect(subject).to receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'flags an expectation made on an unnamed subject' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        it 'uses unnamed subject' do
          expect(subject).to receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'flags one-line expectcation syntax' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        it 'uses one-line expectation syntax' do
          is_expected.to receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'ignores stub within context where subject name changed' do
    expect_no_offenses(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'when I shake things up' do
          subject(:bar) { described_class.new }

          it 'tries to trick rubocop-rspec' do
            allow(foo).to receive(:baz)
          end
        end
      end
    RUBY
  end

  it 'flags stub inside all matcher' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { [Object.new] }
        it 'tries to trick rubocop-rspec' do
          expect(foo).to all(receive(:baz))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'flags nested subject stubs when nested subject uses same name' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'when I shake things up' do
          subject(:foo) { described_class.new }

          before do
            allow(foo).to receive(:wow)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          end

          it 'tries to trick rubocop-rspec' do
            expect(foo).to eql(:neat)
          end
        end
      end
    RUBY
  end

  it 'ignores nested stubs when nested subject is anonymous' do
    expect_no_offenses(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'when I shake things up' do
          subject { described_class.new }

          before do
            allow(foo).to receive(:wow)
          end

          it 'tries to trick rubocop-rspec' do
            expect(foo).to eql(:neat)
          end
        end
      end
    RUBY
  end

  it 'flags nested subject stubs when example group does not define subject' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'when I shake things up' do
          before do
            allow(foo).to receive(:wow)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          end

          it 'tries to trick rubocop-rspec' do
            expect(foo).to eql(:neat)
          end
        end
      end
    RUBY
  end

  it 'flags nested subject stubs' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'when I shake things up' do
          subject(:bar) { described_class.new }

          before do
            allow(foo).to receive(:wow)
            allow(bar).to receive(:wow)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          end

          it 'tries to trick rubocop-rspec' do
            expect(bar).to eql(foo)
          end
        end
      end
    RUBY
  end

  it 'flags nested subject stubs when adjacent context redefines' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'when I do something in a context' do
          subject { blah }
        end

        it 'still flags this test' do
          allow(foo).to receive(:blah)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'flags deeply nested subject stubs' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        context 'level 1' do
          subject(:bar) { described_class.new }

          context 'level 2' do
            subject(:baz) { described_class.new }

            before do
              allow(foo).to receive(:wow)
              allow(bar).to receive(:wow)
              allow(baz).to receive(:wow)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
            end
          end
        end
      end
    RUBY
  end

  it 'flags negated runners' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        specify do
          expect(foo).not_to receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo).to_not receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo.bar).to eq(baz)
        end
      end
    RUBY
  end

  it 'flags multiple-method stubs' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        specify do
          expect(foo).to receive_messages(bar: :baz, baz: :baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo.bar).to eq(baz)
        end
      end
    RUBY
  end

  it 'flags chain stubs' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        specify do
          expect(foo).to receive_message_chain(:bar, baz: :baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
          expect(foo.bar.baz).to eq(baz)
        end
      end
    RUBY
  end

  it 'flags spy subject stubs' do
    expect_offense(<<-RUBY)
      describe Foo do
        subject(:foo) { described_class.new }

        specify do
          allow(foo).to some_matcher_that_allows_a_bar_message
          expect(foo.bar).to eq(baz)
          expect(foo).to have_received(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'flags when an implicit subject is mocked' do
    expect_offense(<<-RUBY)
      describe Foo do
        it 'uses an implicit subject' do
          expect(subject).to receive(:bar).and_return(baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  it 'flags when there are several top level example groups' do
    expect_offense(<<-RUBY)
      RSpec.describe Foo do
        subject(:foo) { described_class.new }

        specify do
          expect(foo).to eq(foo)
        end
      end

      RSpec.describe Bar do
        subject(:bar) { described_class.new }

        specify do
          allow(bar).to receive(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
        end
      end
    RUBY
  end

  describe 'top level example groups' do
    %i[
      describe xdescribe fdescribe
      context xcontext fcontext
      feature xfeature ffeature
      example_group
      shared_examples shared_examples_for shared_context
    ].each do |method|
      it "flags in top level #{method}" do
        expect_offense(<<-RUBY)
          RSpec.#{method} '#{method}' do
            it 'uses an implicit subject' do
              expect(subject).to receive(:bar)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not stub methods of the object under test.
            end
          end
        RUBY
      end
    end
  end
end
