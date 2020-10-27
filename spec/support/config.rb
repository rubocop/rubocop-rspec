# frozen_string_literal: true

RSpec.shared_context 'with RuboCop-RSpec config', :config do
  # This overrides the config defined in the default shared context since
  # RuboCop ignores department-level cop configuration in specs.
  let(:config) do
    department_name = cop_class.badge.department.to_s
    # By default, `RSpec/Include: ['**/*_spec.rb', '**/spec/**/*']`
    department_configuration = RuboCop::ConfigLoader
      .default_configuration
      .for_department(department_name)

    hash = { 'AllCops' => all_cops_config,
             cop_class.cop_name => cur_cop_config,
             department_name => department_configuration }
      .merge!(other_cops)

    RuboCop::Config.new(hash, "#{Dir.pwd}/.rubocop.yml")
  end
end
