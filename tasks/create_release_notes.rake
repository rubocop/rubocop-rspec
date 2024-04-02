# frozen_string_literal: true

desc 'Create release notes for the most recent version.'
task :create_release_notes do
  CreateReleaseNotes.call
end

# Create release notes from the most recent version in the CHANGELOG.md file.
module CreateReleaseNotes
  module_function

  def call
    release_notes = new_version_changes.strip
    contributor_links = user_links(release_notes)

    File.open('relnotes.md', 'w') do |file|
      file << release_notes
      file << "\n\n"
      file << contributor_links
      file << "\n"
    end
  end

  def new_version_changes
    changelog = File.read('CHANGELOG.md')
    _, _, new_changes, _older_changes = changelog.split(/^## .*$/, 4)
    new_changes
  end

  def user_links(text)
    names = text.scan(/\[@(\S+)\]/).map(&:first).uniq.sort
    names.map { |name| "[@#{name}]: https://github.com/#{name}" }.join("\n")
  end
end
