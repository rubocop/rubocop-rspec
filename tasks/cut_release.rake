# frozen_string_literal: true

require 'bump'

namespace :cut_release do
  %w[major minor patch pre].each do |release_type|
    desc "Cut a new #{release_type} release and create release notes."
    task release_type => 'changelog:check_clean' do
      run(release_type)
    end
  end

  def add_header_to_changelog(version)
    update_file('CHANGELOG.md') do |changelog|
      changelog.sub("## Master (Unreleased)\n\n",
                    '\0' "## #{version} (#{Time.now.strftime('%F')})\n\n")
    end
  end

  def update_antora_yml(new_version)
    antora_metadata = File.read('docs/antora.yml')

    File.open('docs/antora.yml', 'w') do |f|
      f << antora_metadata.sub('version: ~',
                               "version: '#{version_sans_patch(new_version)}'")
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

  def new_version_changes
    changelog = File.read('CHANGELOG.md')
    _, _, new_changes, _older_changes = changelog.split(/^## .*$/, 4)
    new_changes
  end

  def update_file(path)
    content = File.read(path)
    File.write(path, yield(content))
  end

  def user_links(text)
    names = text.scan(/\[@(\S+)\]/).map(&:first).uniq
    names.map { |name| "[@#{name}]: https://github.com/#{name}" }.join("\n")
  end

  def update_docs(version)
    update_file('docs/antora.yml') do |antora_metadata|
      antora_metadata.sub('version: ~',
                          "version: '#{version_sans_patch(version)}'")
    end
  end

  def run(release_type)
    old_version = Bump::Bump.current
    Bump::Bump.run(release_type, commit: false, bundle: false, tag: false)
    new_version = Bump::Bump.current

    update_cop_versions(new_version)
    `bundle exec rake generate_cops_documentation`
    update_docs(new_version) if %w[major minor].include?(release_type)

    add_header_to_changelog(new_version)
    update_antora_yml(new_version)

    puts "Changed version from #{old_version} to #{new_version}."
  end
end
