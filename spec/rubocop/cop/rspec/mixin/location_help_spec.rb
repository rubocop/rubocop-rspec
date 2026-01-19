# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::LocationHelp do
  describe 'LocationHelp.arguments_with_whitespace' do
    subject(:arguments_with_whitespace) do
      described_class.arguments_with_whitespace(source_ast)
    end

    let(:source_ast) { parse_source(source).ast }

    context 'when `a b`' do
      let(:source) { 'a b' }

      it 'returns #<Parser::Source::Range (string) 1...3>' do
        expect(arguments_with_whitespace).to have_attributes(
          begin_pos: 1,
          end_pos: 3
        )
      end
    end

    context 'when `foo 1, 2`' do
      let(:source) { 'foo 1, 2' }

      it 'returns #<Parser::Source::Range (string) 3...8>' do
        expect(arguments_with_whitespace).to have_attributes(
          begin_pos: 3,
          end_pos: 8
        )
      end
    end

    context 'when `foo(bar, baz)`' do
      let(:source) { 'foo(bar, baz)' }

      it 'returns #<Parser::Source::Range (string) 3...13>' do
        expect(arguments_with_whitespace).to have_attributes(
          begin_pos: 3,
          end_pos: 13
        )
      end
    end
  end

  describe 'LocationHelp.block_with_whitespace' do
    subject(:block_with_whitespace) do
      described_class.block_with_whitespace(source_ast)
    end

    context 'when `a b`' do
      let(:source_ast) { parse_source(source).ast }
      let(:source) { 'a b' }

      it 'returns nil' do
        expect(block_with_whitespace).to be_nil
      end
    end

    context 'when `a.b`' do
      let(:source_ast) { parse_source(source).ast.children.first }
      let(:source) { 'a.b' }

      it 'returns nil' do
        expect(block_with_whitespace).to be_nil
      end
    end

    context 'when `a { b }`' do
      let(:source_ast) { parse_source(source).ast.children.first }
      let(:source) { 'a { b }' }

      it 'returns #<Parser::Source::Range (string) 1...7>' do
        expect(block_with_whitespace).to have_attributes(
          begin_pos: 1,
          end_pos: 7
        )
      end
    end

    context 'when `foo { bar + baz }`' do
      let(:source_ast) { parse_source(source).ast.children.first }
      let(:source) { 'foo { bar + baz }' }

      it 'returns #<Parser::Source::Range (string) 3...17>' do
        expect(block_with_whitespace).to have_attributes(
          begin_pos: 3,
          end_pos: 17
        )
      end
    end
  end
end
