# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LetSetup do
  it 'complains when let! is used and not referenced' do
    expect_offense(<<~RUBY)
      describe Foo do
        let!(:foo) { bar }
        ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

        it 'does not use foo' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'ignores let! when used in `before`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let!(:foo) { bar }

        before do
          foo
        end

        it 'does not use foo' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'ignores let! when used in example' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let!(:foo) { bar }

        it 'uses foo' do
          foo
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'complains when let! is used and not referenced within nested group' do
    expect_offense(<<~RUBY)
      describe Foo do
        context 'when something special happens' do
          let!(:foo) { bar }
          ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'does not use foo' do
            expect(baz).to eq(qux)
          end
        end

        it 'references some other foo' do
          foo
        end
      end
    RUBY
  end

  it 'complains when let! is used and not referenced in shared example group' do
    expect_offense(<<~RUBY)
      shared_context 'foo' do
        let!(:bar) { baz }
        ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

        it 'does not use bar' do
          expect(baz).to eq(qux)
        end
      end
    RUBY
  end

  it 'complains when let! used in shared example including' do
    expect_offense(<<~RUBY)
      describe Foo do
        it_behaves_like 'bar' do
          let!(:baz) { foobar }
          ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
          let(:a) { b }
        end
      end
    RUBY
  end

  it 'complains when there is only one nested node into example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        let!(:bar) { baz }
        ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
      end
    RUBY
  end

  it 'flags unused helpers defined as strings' do
    expect_offense(<<~RUBY)
      describe Foo do
        let!('bar') { baz }
        ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
      end
    RUBY
  end

  it 'ignores used helpers defined as strings' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let!('bar') { baz }
        it { expect(bar).to be_near }
      end
    RUBY
  end

  it 'flags blockpass' do
    expect_offense(<<~RUBY)
      shared_context Foo do |&block|
        let!(:bar, &block)
        ^^^^^^^^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
      end
    RUBY
  end

  it 'complains when there is a custom nesting level' do
    expect_offense(<<~RUBY)
      describe Foo do
        [].each do |i|
          let!(:bar) { i }
          ^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'does not use bar' do
            expect(baz).to eq(qux)
          end
        end
      end
    RUBY
  end

  it 'ignores let! that overrides outer scope let!' do
    expect_no_offenses(<<~RUBY)
      describe User, type: :model do
        let!(:user) { create(:user) }

        it 'is valid' do
          expect(user).to be_valid
        end

        context 'with no direct usage' do
          let!(:user) { create(:user, :special) }

          it 'creates something' do
            expect(SomeModel.count).to eq(2)
          end
        end
      end
    RUBY
  end

  it 'ignores let! overriding outer scope across multiple nesting levels' do
    expect_no_offenses(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        context 'level 1' do
          context 'level 2' do
            let!(:user) { create(:user, :admin) }

            it 'creates admin user' do
              expect(User.count).to eq(2)
            end
          end
        end
      end
    RUBY
  end

  it 'still flags unused let! when outer scope has different name' do
    expect_offense(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        context 'different variable' do
          let!(:admin) { create(:user, :admin) }
          ^^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'creates admin user' do
            expect(User.count).to eq(2)
          end
        end
      end
    RUBY
  end

  it 'allows let! override when outer let! is used elsewhere' do
    expect_no_offenses(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        context 'special case' do
          let!(:user) { create(:user, :special) }

          it 'setup only' do
            expect(User.count).to eq(2)
          end
        end
      end
    RUBY
  end

  it 'does not consider non-RSpec blocks as outer scope' do
    expect_offense(<<~RUBY)
      describe User do
        [1, 2, 3].each do |i|
          let!(:user) { create(:user, id: i) }
          ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'creates user' do
            expect(User.count).to eq(3)
          end
        end
      end
    RUBY
  end

  it 'correctly identifies override through mixed block types' do
    expect_no_offenses(<<~RUBY)
      describe User do
        let!(:user) { create(:user) }

        it 'uses user' do
          expect(user).to be_valid
        end

        [true, false].each do |flag|
          context "when flag is \#{flag}" do
            let!(:user) { create(:user, flag: flag) }

            it 'setup only' do
              expect(User.count).to be > 0
            end
          end
        end
      end
    RUBY
  end

  context 'with a project index', :project_index do
    let(:foo_spec_path) { File.expand_path('spec/foo_spec.rb') }
    let(:shared_path) { File.expand_path('spec/support/shared.rb') }

    def index(sources)
      build_index(sources.transform_keys { |path| "file://#{path}" })
    end

    def reference_names_for(source)
      cop = described_class.new
      cop.project_index = index(foo_spec_path => source)
      [cop, cop.send(:project_index_reference_names)]
    end

    it 'does not flag let! referenced from shared examples in another file' do
      source = <<~RUBY
        describe Foo do
          context 'ctx' do
            let!(:user) { create(:user) }
            include_examples 'shared example'
          end
        end
      RUBY
      shared = <<~RUBY
        RSpec.shared_examples 'shared example' do
          it { expect(user).to be_present }
        end
      RUBY
      cop.project_index = index(foo_spec_path => source, shared_path => shared)

      expect_no_offenses(source, foo_spec_path)
    end

    it 'does not flag let! referenced from a shared context in another file' do
      source = <<~RUBY
        describe Foo do
          context 'ctx' do
            let!(:record) { create(:record) }
            include_context 'a local record'
          end
        end
      RUBY
      shared = <<~RUBY
        RSpec.shared_context 'a local record' do
          before { record.sync }
        end
      RUBY
      cop.project_index = index(foo_spec_path => source, shared_path => shared)

      expect_no_offenses(source, foo_spec_path)
    end

    it 'does not flag let! defined in a shared context and referenced ' \
       'from the file that includes it' do
      shared = <<~RUBY
        RSpec.shared_context 'a local record' do
          let!(:record) { create(:record) }
        end
      RUBY
      other = <<~RUBY
        describe Foo do
          include_context 'a local record'
          it { expect(record).to be_present }
        end
      RUBY
      cop.project_index =
        index(shared_path => shared, foo_spec_path => other)

      expect_no_offenses(shared, shared_path)
    end

    it 'does not flag let! referenced from a shared context included ' \
       "inside an ancestor's ordinary Ruby block" do
      source = <<~RUBY
        describe Foo do
          %w[a b].each { |variant| include_context "shared \#{variant}" }

          context 'ctx' do
            let!(:record) { create(:record) }
          end
        end
      RUBY
      shared = <<~RUBY
        RSpec.shared_context 'shared a' do
          before { record.sync }
        end
      RUBY
      cop.project_index = index(foo_spec_path => source, shared_path => shared)

      expect_no_offenses(source, foo_spec_path)
    end

    it 'does not flag let! referenced from a shared context included ' \
       "via an ancestor's block-form inclusion" do
      source = <<~RUBY
        describe Foo do
          include_context 'shared' do
            let(:variant) { 'a' }
          end

          context 'ctx' do
            let!(:record) { create(:record) }
          end
        end
      RUBY
      shared = <<~RUBY
        RSpec.shared_context 'shared' do
          before { record.sync }
        end
      RUBY
      cop.project_index = index(foo_spec_path => source, shared_path => shared)

      expect_no_offenses(source, foo_spec_path)
    end

    it 'still flags let! never referenced anywhere in the project' do
      source = <<~RUBY
        describe Foo do
          context 'ctx' do
            let!(:user) { create(:user) }
            ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
            include_examples 'shared example'
          end
        end
      RUBY
      shared = <<~RUBY
        RSpec.shared_examples 'shared example' do
          it { expect(1).to eq(1) }
        end
      RUBY
      cop.project_index = index(foo_spec_path => source, shared_path => shared)

      expect_offense(source, foo_spec_path)
    end

    it 'still flags let! not connected to shared code ' \
       'even when a sibling context includes it' do
      source = <<~RUBY
        describe Foo do
          context 'without shared code' do
            let!(:user) { create(:user) }
            ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.
          end

          context 'with shared code' do
            include_examples 'shared example'
          end
        end
      RUBY
      shared = <<~RUBY
        RSpec.shared_examples 'shared example' do
          it { expect(user).to be_present }
        end
      RUBY
      cop.project_index = index(foo_spec_path => source, shared_path => shared)

      expect_offense(source, foo_spec_path)
    end

    it 'still flags unused let! not connected to shared code ' \
       'even when the name is used elsewhere' do
      source = <<~RUBY
        describe Foo do
          let!(:user) { create(:user) }
          ^^^^^^^^^^^ Do not use `let!` to setup objects not referenced in tests.

          it 'does not use user' do
            expect(baz).to eq(qux)
          end
        end
      RUBY
      other = <<~RUBY
        describe Bar do
          it { expect(user).to be_present }
        end
      RUBY
      bar_spec_path = File.expand_path('spec/bar_spec.rb')
      cop.project_index =
        index(foo_spec_path => source, bar_spec_path => other)

      expect_offense(source, foo_spec_path)
    end

    describe 'the reference-name cache' do
      it 'is computed once per index and shared across cop instances' do
        source = <<~RUBY
          describe Foo do
            it { expect(user).to be_present }
          end
        RUBY
        project_index = index(foo_spec_path => source)

        first_cop = described_class.new
        first_cop.project_index = project_index
        first_cop_names = first_cop.send(:project_index_reference_names)

        second_cop = described_class.new
        second_cop.project_index = project_index
        second_cop_names = second_cop.send(:project_index_reference_names)

        expect(second_cop_names).to be(first_cop_names)
      end

      it 'replaces the cached entry when the index changes, rather than ' \
         'accumulating it', :aggregate_failures do
        _, first_cop_names = reference_names_for(<<~RUBY)
          describe Foo do
            it { expect(user).to be_present }
          end
        RUBY

        second_cop, second_cop_names = reference_names_for(<<~RUBY)
          describe Foo do
            it { expect(1).to eq(1) }
          end
        RUBY

        expect(second_cop_names).not_to eq(first_cop_names)

        index_object, cached = described_class.cached_reference_names
        expect(index_object).to be(second_cop.project_index)
        expect(cached).to be(second_cop_names)
      end
    end
  end
end
