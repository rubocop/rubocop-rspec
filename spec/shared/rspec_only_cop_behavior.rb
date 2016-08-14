module SpecHelper
  # Provides a helper method for checking that `cop` works
  #
  # @note this is defined in a module so that the failure message can be
  #   a constant without creating a bunch of warnings when the shared
  #   context is included
  #
  module CheckCop
    CURRENT_FILE = Pathname.new(__FILE__).relative_path_from(ROOT).freeze

    FAILURE = <<-MSG.freeze
      Attempting to access `cop` produced the following error:

        %<exception>s

      The shared context under #{CURRENT_FILE} is included for all RSpec
      cops. This context expects you to define a subject named `cop` like so:

        describe RuboCop::Cop::RSpec::SomeCheck do
          subject(:cop) { described_class.new }

          ...
        end

      or if your cop is configurable you should have something like:

        describe RuboCop::Cop::RSpec::SomeConfigurableCheck, :config do
          subject(:cop) { described_class.new(config) }

          let(:cop_config) do
            { 'EnforcedStyle' => 'fancy', 'WhateverElse' => 'YouNeed' }
          end

          ...
        end

      This error likely means that you either don't define `cop` at the top
      level or you have dependent definitions (like `cop_config`) that are not
      defined at the top level.
    MSG

    # This method exists to reduce confusion for contributors. It is important
    # that these shared examples are automatically included for all cops but
    # it is easy for these to fail if you don't realize that your top level
    # describe needs to define a useable `cop` subject.
    def check_cop_definition
      cop
    rescue => exception
      raise format(FAILURE, exception: exception)
    end
  end
end

RSpec.shared_examples 'an rspec only cop', rspec_cop: true do
  include SpecHelper::CheckCop

  before do
    check_cop_definition
  end

  it 'does not deem lib/feature/thing.rb to be a relevant file' do
    expect(cop.relevant_file?('lib/feature/thing.rb')).to be_falsey
  end

  it 'deems spec/feature/thing_spec.rb to be a relevant file' do
    expect(cop.relevant_file?('spec/feature/thing_spec.rb')).to be(true)
  end
end
