# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::SkipOrPending do
  describe '#skipped_in_metadata?' do
    subject(:skipped_in_metadata?) do
      stub_class.new.send(:skipped_in_metadata?, ast)
    end

    let(:stub_class) do
      Class.new do
        include RuboCop::Cop::RSpec::SkipOrPending
      end
    end
    let(:ast) { parse_source(source).ast.children.first }

    context 'when given node contains skip' do
      let(:source) { <<~RUBY }
        it 'is skipped', :skip do
          foo
        end
      RUBY

      it 'returns true' do
        expect(skipped_in_metadata?).to be_truthy
      end
    end

    context 'when given node contains pending' do
      let(:source) { <<~RUBY }
        it 'is pending', :pending do
          foo
        end
      RUBY

      it 'returns true' do
        expect(skipped_in_metadata?).to be_truthy
      end
    end

    context 'when given node does not contain skip/pending' do
      let(:source) { 'it("example") { }' }

      it 'returns false' do
        expect(skipped_in_metadata?).to be_falsey
      end
    end
  end

  describe '#skip_or_pending_inside_block?' do
    subject(:skip_or_pending_inside_block?) do
      stub_class.new.send(:skip_or_pending_inside_block?, ast)
    end

    let(:stub_class) do
      Class.new do
        include RuboCop::Cop::RSpec::SkipOrPending
      end
    end
    let(:ast) { parse_source(source).ast }

    context 'when given node contains skip inside block' do
      let(:source) do
        <<~RUBY
          context 'when color is blue' do
            skip 'not implemented yet'
          end
        RUBY
      end

      it 'returns true' do
        expect(skip_or_pending_inside_block?).to be_truthy
      end
    end

    context 'when given node contains pending inside block' do
      let(:source) do
        <<~RUBY
          context 'when color is blue' do
            pending 'not implemented yet'
          end
        RUBY
      end

      it 'returns true' do
        expect(skip_or_pending_inside_block?).to be_truthy
      end
    end

    context 'when given node does not contain skip inside block' do
      let(:source) { "skip 'not implemented yet'" }

      it 'returns false' do
        expect(skip_or_pending_inside_block?).to be_falsey
      end
    end

    context 'when given node does not contain pending inside block' do
      let(:source) { "pending 'not implemented yet'" }

      it 'returns false' do
        expect(skip_or_pending_inside_block?).to be_falsey
      end
    end
  end
end
