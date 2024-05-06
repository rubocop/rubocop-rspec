# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::RepeatedSubjectCall do
  it 'registers an offense when a singular block' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        it do
          subject
          expect { subject }.to not_change { Foo.count }
          ^^^^^^^^^^^^^^^^^^ Calls to subject are memoized, this block is misleading
        end
      end
    RUBY
  end

  it 'registers an offense when repeated blocks' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect { subject }.to change { Foo.count }
          expect { subject }.to not_change { Foo.count }
          ^^^^^^^^^^^^^^^^^^ Calls to subject are memoized, this block is misleading
        end
      end
    RUBY
  end

  it 'registers an offense when nested blocks' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect(subject.a).to eq(3)
          nested_block do
            expect { on_shard(:europe) { subject } }.to not_change { Foo.count }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Calls to subject are memoized, this block is misleading
          end
        end
      end
    RUBY
  end

  it 'registers an offense when custom subjects' do
    expect_offense(<<~RUBY)
      RSpec.describe Foo do
        subject(:bar) { do_something }

        it do
          bar
          expect { bar }.to not_change { Foo.count }
          ^^^^^^^^^^^^^^ Calls to subject are memoized, this block is misleading
        end
      end
    RUBY
  end

  it 'does not register an offense when no block' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect(subject.a).to eq(3)
          expect(subject.b).to eq(4)
        end
      end
    RUBY
  end

  it 'does not register an offense when block first' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect { subject }.to change { Foo.count }
          expect(subject.b).to eq(4)
        end
      end
    RUBY
  end

  it 'does not register an offense when different subjects' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        subject { do_something_else }
        subject(:bar) { do_something }

        it do
          expect { bar }.to not_change { Foo.count }
          expect { subject }.to not_change { Foo.count }
        end
      end
    RUBY
  end

  it 'does not register an offense when multiple no description it blocks' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect { subject }.to change { Foo.count }
        end

        it do
          expect(subject.b).to eq(4)
        end
      end
    RUBY
  end

  it 'does not register an offense when `subject.method_call`' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect { subject.a }.to change { A.count }
          expect { subject.b }.to not_change { A.count }
        end
      end
    RUBY
  end

  it 'does not register an offense when `subject` as an argument' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        it do
          expect { create(:bar, baz: subject) }.to change { A.count }
          expect { create(:bar, subject) }.to not_change { A.count }
        end
      end
    RUBY
  end

  it 'does not register an offense when `subject` with not expectation' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        it do
          allow(Foo).to receive(:bar).and_return(subject)
          allow(Foo).to receive(:bar) { subject }
        end
      end
    RUBY
  end

  it 'does not register an offense when `subject` not inside example' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe Foo do
        subject { do_something }

        it do
          expect { subject }.to change { Foo.count }
        end
      end
    RUBY
  end

  it 'does not register an offense when `subject` is not inside describe' do
    expect_no_offenses(<<~RUBY)
      Foo.subject(:bar)
      subject(:bar)
      subject
    RUBY
  end
end
