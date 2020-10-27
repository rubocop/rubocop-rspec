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
end
