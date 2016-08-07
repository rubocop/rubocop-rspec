module RuboCop
  # RuboCop RSpec project namespace
  module RSpec
    PROJECT_ROOT   = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join('config', 'default.yml').freeze
    CONFIG         = YAML.load(CONFIG_DEFAULT.read).freeze

    private_constant(*constants(false))
  end
end
