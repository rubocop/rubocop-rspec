# frozen_string_literal: true

require 'rubocop'
require 'rubocop-rspec'
require 'rubocop/cops_documentation_generator'
require 'yard'

# Monkey patch to normalize Hash formatting regardless of Ruby version
class CopsDocumentationGenerator
  private

  # Override to normalize Hash values to Ruby 3.4+ format
  def format_table_value(val)
    value =
      case val
      when Array
        if val.empty?
          '`[]`'
        else
          val.map { |config| format_table_value(config) }.join(', ')
        end
      when Hash
        # Normalize Hash to Ruby 3.4+ format with spaces around =>
        normalize_hash(val)
      else
        wrap_backtick(val.nil? ? '<none>' : val)
      end
    value.gsub("#{@base_dir}/", '').rstrip
  end

  def normalize_hash(hash)
    return '`{}`' if hash.empty?

    pairs = hash.map do |key, value|
      formatted_key = key.inspect
      formatted_value = value.is_a?(String) ? value.inspect : value.to_s

      # Use symbol colon syntax for symbol keys, hash rocket for others
      if key.is_a?(Symbol)
        "#{key}: #{formatted_value}"
      else
        "#{formatted_key} => #{formatted_value}"
      end
    end

    "`{#{pairs.join(', ')}}`"
  end
end

YARD::Rake::YardocTask.new(:yard_for_generate_documentation) do |task|
  task.files = ['lib/rubocop/cop/**/*.rb']
  task.options = ['--no-output']
end

desc 'Generate docs of all cops departments'
task generate_cops_documentation: :yard_for_generate_documentation do
  generator = CopsDocumentationGenerator.new(
    departments: %w[RSpec], plugin_name: 'rubocop-rspec'
  )
  generator.call
end

desc 'Syntax check for the documentation comments'
task documentation_syntax_check: :yard_for_generate_documentation do
  require 'parser/ruby25'

  ok = true
  YARD::Registry.load!
  cops = RuboCop::Cop::Registry.global
  cops.each do |cop|
    examples = YARD::Registry.all(:class).find do |code_object|
      next unless RuboCop::Cop::Badge.for(code_object.to_s) == cop.badge

      break code_object.tags('example')
    end

    examples.to_a.each do |example|
      buffer = Parser::Source::Buffer.new('<code>', 1)
      buffer.source = example.text
      parser = Parser::Ruby25.new(RuboCop::AST::Builder.new)
      parser.diagnostics.all_errors_are_fatal = true
      parser.parse(buffer)
    rescue Parser::SyntaxError => e
      path = example.object.file
      puts "#{path}: Syntax Error in an example. #{e}"
      ok = false
    end
  end
  abort unless ok
end
