# frozen_string_literal: true

require 'bump'

namespace :cut_release do
  def update_file(path)
    content = File.read(path)
    File.write(path, yield(content))
  end

  %w[major minor patch pre].each do |release_type|
    desc "Cut a new #{release_type} release and update documents."
    task release_type do
      run(release_type)
    end
  end

  def version_sans_patch(version)
    version.split('.').take(2).join('.')
  end

  # Replace `<<next>>` (and variations) with version being cut.
  def update_cop_versions(version)
    update_file('config/default.yml') do |default|
      default.gsub(/['"]?<<\s*next\s*>>['"]?/i,
                   "'#{version_sans_patch(version)}'")
    end
    RuboCop::ConfigLoader.default_configuration = nil # invalidate loaded conf
  end

  def update_docs(version)
    update_file('docs/antora.yml') do |antora_metadata|
      antora_metadata.sub('version: master',
                          "version: '#{version_sans_patch(version)}'")
    end
  end

  def add_header_to_changelog(version)
    update_file('CHANGELOG.md') do |changelog|
      changelog.sub("## Master (Unreleased)\n\n",
                    '\0' "## #{version} (#{Time.now.strftime('%F')})\n\n")
    end
  end

  def run(release_type)
    old_version = Bump::Bump.current
    Bump::Bump.run(release_type, commit: false, bundle: false, tag: false)
    new_version = Bump::Bump.current

    update_cop_versions(new_version)
    `bundle exec rake generate_cops_documentation`
    update_docs(new_version)
    add_header_to_changelog(new_version)

    puts "Changed version from #{old_version} to #{new_version}."
  end
end
