# frozen_string_literal: true

# rubocop-rspec gem extension of RuboCop's ExpectOffense module.
#
# This mixin is the same as rubocop's ExpectOffense except the default
# filename ends with `_spec.rb`
#
# Cops assigned to departments may focus on different files, so it is
# possible to override the inspected file name.
module ExpectOffense
  include RuboCop::RSpec::ExpectOffense

  DEFAULT_FILENAME = 'example_spec.rb'

  def expect_offense(source, filename = inspected_source_filename,
                     *args, **kwargs)
    super
  end

  def expect_no_offenses(source, filename = inspected_source_filename)
    super
  end

  def inspected_source_filename
    DEFAULT_FILENAME
  end

  def expect_global_offense(source, file = nil, message = '')
    processed_source = parse_source(source, file)
    offenses = _investigate(cop, processed_source)
    expect(offenses.size).to eq(1)
    expect(offenses.first.message).to eq(message)
  end

  def expect_no_global_offenses(source, file = nil)
    processed_source = parse_source(source, file)
    offenses = _investigate(cop, processed_source)
    expect(offenses.size).to eq(0)
  end
end
