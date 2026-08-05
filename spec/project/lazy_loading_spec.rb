# frozen_string_literal: true

RSpec.describe 'cop lazy loading' do
  def run_script(source)
    Dir.mktmpdir do |dir|
      script = File.join(dir, 'script.rb')
      File.write(script, source)
      lib = File.expand_path('../../lib', __dir__)
      output = `#{RbConfig.ruby} -I #{lib} #{script} 2>&1`
      raise "script failed:\n#{output}" unless $CHILD_STATUS.success?

      output
    end
  end

  it 'registers every cop file in `lib/rubocop/cop/rspec` exactly once' do
    cop_root = File.expand_path('../../lib/rubocop/cop', __dir__)
    files = Dir[File.join(cop_root, 'rspec', '*.rb')].sort
    files -= [File.join(cop_root, 'rspec', 'base.rb'),
              File.join(cop_root, 'rspec', 'mixin.rb')]

    department = RuboCop::Cop::Registry.global.cops_for_department(:RSpec)
    locations = department.filter_map do |cop|
      # Cop classes stubbed by other specs have no source location or live
      # outside lib; only the gem's own cops are checked here.
      Object.const_source_location(cop.name)&.first
    end
    registered = locations.select { |path| path.start_with?(cop_root) }

    expect(registered.sort).to eq(files)
  end

  it 'registers all cops without loading their files' do
    output = run_script(<<~RUBY)
      require 'rubocop-rspec'

      registry = RuboCop::Cop::Registry.global
      loaded = $LOADED_FEATURES.grep(%r{/rubocop/cop/rspec/(?!mixin)(?!base\\.rb)})

      puts "registered=\#{registry.names.grep(%r{\\ARSpec/}).size}"
      puts "loaded_cop_files=\#{loaded.size}"
    RUBY

    expect(output).to include('registered=115', 'loaded_cop_files=0')
  end

  it 'resolves every mixin file in `lib/rubocop/cop/rspec/mixin` through ' \
     'an autoload' do
    mixin_root = File.expand_path('../../lib/rubocop/cop/rspec/mixin', __dir__)

    output = run_script(<<~RUBY)
      require 'rubocop-rspec'

      resolved = Dir[File.join('#{mixin_root}', '*.rb')].sort.all? do |file|
        name = File.basename(file, '.rb').split('_').map(&:capitalize).join
        RuboCop::Cop::RSpec.const_get(name)
        Object.const_source_location("RuboCop::Cop::RSpec::\#{name}").first == file
      end

      puts "resolved=\#{resolved}"
    RUBY

    expect(output).to include('resolved=true')
  end

  it 'loads mixins on demand rather than at require time' do
    output = run_script(<<~RUBY)
      require 'rubocop-rspec'

      loaded = $LOADED_FEATURES.grep(%r{/rubocop/cop/rspec/mixin/}).map do |path|
        File.basename(path)
      end

      puts "loaded_mixin_files=\#{loaded.sort.join(',')}"
    RUBY

    # `RuboCop::RSpec::Corrector::MoveNode` includes `CommentsHelp` and
    # `FinalEndLocation` when it is loaded, which triggers their autoloads.
    expect(output).to include(
      'loaded_mixin_files=comments_help.rb,final_end_location.rb'
    )
  end

  it 'does not register a cop twice when its file is required directly' do
    output = run_script(<<~RUBY)
      require 'rubocop-rspec'

      before = RuboCop::Cop::Registry.global.length
      require 'rubocop/cop/rspec/be'
      after = RuboCop::Cop::Registry.global.length

      puts "stable=\#{before == after}"
      puts "class=\#{RuboCop::Cop::Registry.global.find_by_cop_name('RSpec/Be')}"
    RUBY

    expect(output).to include('stable=true', 'class=RuboCop::Cop::RSpec::Be')
  end
end
